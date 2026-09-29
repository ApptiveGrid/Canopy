# Canopy

A foundation for managing global values in Pharo.

Canopy keeps the global values of an image in one tree: configuration read from files, and
metrics read from running components. Both are the same kind of node. Only the direction differs:
a configuration value is written *into* a component, a metric is read *out of* one. Components
declare their part of the tree with pragmas, so they never depend on a particular configuration
format or metrics library, and the configuration file does not have to mirror the structure of
the components.

- [Installation](#installation)
- [Packages](#packages)
- [Concepts](#concepts)
- [The tree](#the-tree)
- [Domains and the singleton](#domains-and-the-singleton)
- [Importing configuration](#importing-configuration)
- [Binding components](#binding-components)
- [Merge and apply](#merge-and-apply)
- [Tags](#tags)
- [Labels](#labels)
- [Metrics](#metrics)
- [Prometheus export](#prometheus-export)
- [Browsing and editing over HTTP](#browsing-and-editing-over-http)
- [Tests and the singleton](#tests-and-the-singleton)
- [Errors](#errors)
- [Development](#development)

## Installation

```smalltalk
Metacello new
	baseline: 'Canopy';
	repository: 'github://ApptiveGrid/Canopy:main/source';
	load.
```

To load only the configuration part, without metrics and tests:

```smalltalk
Metacello new
	baseline: 'Canopy';
	repository: 'github://ApptiveGrid/Canopy:main/source';
	load: #( 'Canopy-Core' ).
```

As a dependency in a baseline:

```smalltalk
spec
	baseline: 'Canopy'
	with: [ spec repository: 'github://ApptiveGrid/Canopy:main/source' ].
```

CI runs on Pharo 11, 12 and 13. Pharo 14 is built as well but allowed to fail.

## Packages

| Package | Contents | Requires |
|---|---|---|
| `Canopy-Core` | the tree, JSON import, pragma mapping, merge/apply, tags, labels, value holders, the JSON/HTML browse handlers | STON, Zinc (both part of Pharo) |
| `Canopy-Metrics` | `CanopyMetric`/`CanopyMetricMap`, the Prometheus exporter and scrape handler, VM/image metrics, the Zinc request counter | `Canopy-Core` |
| `Canopy-Core-Tests` | tests for the core | `Canopy-Core` |
| `Canopy-Metrics-Tests` | tests for the metrics | `Canopy-Metrics` |

## Concepts

```
Canopy (singleton, is a CanopyBranchNode)
├── #pharo                         ← a domain
│   ├── #image
│   │   ├── processesActive        ← CanopyAccessor, reads Process class
│   │   └── fileRegistrySize
│   └── #virtualMachine
│       ├── memorySize
│       └── maxExternalSemaphores  ← read and written through one leaf
├── #zinc
│   ├── httpRequests
│   └── httpResponses              ← one Prometheus line per status code
└── #myServer
    └── #httpServer
        └── port                   ← CanopyCell, imported from a JSON file
```

| Class | Role |
|---|---|
| `CanopyNode` | abstract node: parent, tags, labels |
| `CanopyBranchNode` | a node with named children |
| `CanopyLeafNode` | abstract leaf |
| `CanopyCell` | a leaf holding a raw value from a source, e.g. a JSON file |
| `CanopyAccessor` | a leaf bound to a live object through a read selector, a write selector, or both |
| `Canopy` | the singleton root; its top-level children are the *domains* |
| `CanopyMappingBuilder` | builds a component's subtree from its pragmas |
| `CanopyValueHolder` | abstract holder around a value read from an accessor |
| `CanopyValue` | the plain holder: a value and nothing else |
| `CanopyMetric` / `CanopyMetricMap` | holders that also carry what a Prometheus line needs (`Canopy-Metrics`) |
| `CanopyVisitor` | minimal visitor base, `CanopyPrometheusVisitor` builds on it |

There is no separate metric node type. A metric is what an accessor answers when it is read: if the
answer is a `CanopyMetric`, the exporter writes it, otherwise it does not.

## The tree

Paths are navigated with binary selectors:

| Selector | Meaning |
|---|---|
| `/ key` | the child at `key`; signals `NotFound` if there is none |
| `/+ key` | the child at `key`, creating an empty branch if there is none |
| `@ key` | the *value* of the child at `key` |
| `, aBranch` | merge `aBranch` into the receiver |

`Canopy / #key` and `Canopy /+ #key` work on the class side and go to the singleton.

```smalltalk
(Canopy /+ #myServer /+ #httpServer) at: #port put: (CanopyCell new value: 8080).
Canopy / #myServer / #httpServer @ #port.   "8080"
(Canopy / #myServer / #httpServer / #port) printString.   "'/myServer/httpServer/port[8080]'"
```

Every node knows its path by walking up its parents: `key` is its own key, `allKeys` the keys from
the root down, `fullKey` those keys joined with `_` (`pharo_virtualMachine_memorySize`). That joined
key is the metric name in the Prometheus export.

`asRawValue` turns any node back into plain Smalltalk objects: a branch becomes a nested
`Dictionary`, a leaf its value. It is the inverse of `asCanopyNode` and the basis of the JSON views.

## Domains and the singleton

`Canopy instance` is created lazily and holds all domains. A domain is simply the node registered
under a top-level key; there is no domain class. Two ways to create one:

```smalltalk
"Exactly once. A second registration under the same name is an error."
Canopy registerDomainNamed: #myServer with: aNode.

"Idempotent. Several contributors may fill the same domain."
(Canopy /+ #pharo /+ #image) merge: aSubtree.

Canopy domainNames.   "the top-level keys"
Canopy domains.       "the domain nodes"
Canopy reset.         "drop the whole tree"
```

Registration is decentralised: a class that contributes to the tree implements a class-side
`canopyRegister` and knows its own place. There is no central list, no image-wide pragma scan and
no startup hook. Whoever wants the values calls the registration:

```smalltalk
Canopy registerSystemMetrics.   "#pharo: image and virtual machine metrics"
Canopy registerZincMetrics.     "#zinc: counts Zinc server traffic, subscribes to ZnLogEvent"
```

## Importing configuration

JSON (read with STON) becomes a tree: objects become branches, everything else becomes
`CanopyCell` leaves.

```smalltalk
| tree |
tree := Canopy new importTree: '{ "httpServer" : { "port" : 8080, "host" : "localhost" } }'.
tree / #httpServer @ #port.   "8080"

'{ "a" : 1 }' asCanopy.                             "from a String"
'/etc/myapp/config.json' asFileReference asCanopy.  "from a file"
```

`importTree:` merges into the receiver. Importing again overwrites values that already exist and
adds new ones; the last import wins. `importTree:tags:` additionally tags every imported node, see
[Tags](#tags).

## Binding components

Two ways to connect a component to the tree.

### Explicit: `canopyBind:keys:`

The component names the branch and the keys it wants. For each key it gets a write accessor
(`#port` is written through `port:`), registered as a dependent of the cell. The current value is
written immediately, and every later change of the cell is pushed again, including a re-import of
the configuration file.

```smalltalk
MyServer >> setupConfiguration
	self canopyBind: (Canopy / #myServer / #httpServer) keys: #( port host )
```

```smalltalk
(Canopy / #myServer) importTree: '{ "httpServer" : { "port" : 9090 } }'.
"the bound server now has port 9090"
```

### Declarative: pragmas

A component declares its leaves with `<canopyValue: #key>`. The arity of the method decides the
direction: a method without arguments is read, a method with one argument is written. A read and a
write declaration for the same key give one leaf that can be both read and written.

```smalltalk
MyServer >> portCanopy
	<canopyValue: #port>
	^ port

MyServer >> portCanopy: anInteger
	<canopyValue: #port>
	port := anInteger
```

Two declarations in the same direction for one key are an error. The older form
`<canopyValue: #key type: … arguments: …>` is still read, so existing declarations keep working;
its type and arguments are ignored.

`canopyMapping` builds the component's subtree from those pragmas. `canopySetupFrom:` and
`canopySetupFromFile:` build it and apply a JSON configuration to it in one step:

```smalltalk
MyServer new canopySetupFrom: '{ "port" : 8080 }'.
MyServer new canopySetupFromFile: '/etc/myapp/server.json'.
```

### Composition: `<canopyBranch>`

A component made of other components marks a method with `<canopyBranch>`. It receives the
builder and hangs its parts under keys of its own; each part contributes its own pragmas.

```smalltalk
MyApp >> canopyBranch: aBuilder
	<canopyBranch>
	aBuilder at: #httpServer addMapping: httpServer.
	aBuilder at: #database addMapping: database
```

Every `<canopyBranch>` method in the class hierarchy is sent once, so a subclass can add a branch
method without losing the inherited one; an override replaces the method it overrides. A
`Dictionary` already implements `<canopyBranch>`: each of its values is mapped under its key.

### Taking a subtree as a whole

A write method may receive a whole part of the configuration. When `apply:` meets a leaf where the
configuration has an object, the leaf gets that object as one plain nested `Dictionary`. The
component decides itself whether to replace its state or merge into it:

```smalltalk
MyComponent >> settingsCanopy: aDictionary
	<canopyValue: #settings>
	settings addAll: aDictionary
```

## Merge and apply

Two separate operations.

**Merge** combines two trees into one, for example two configuration files. Branches merge
recursively; a cell takes the incoming cell's value and adds its tags. Every combination without a
defined meaning signals `Error: 'conflict'`: a branch against a leaf, a cell against an accessor,
two accessors bound to different objects. The exception is an accessor that declares exactly the
same thing again (same object by identity, same selectors). That is no conflict, so a component can
register itself a second time when an image runs its setup again.

**Apply** writes values. `componentTree apply: valueTree` walks the value tree and, for every key
the component tree also has, pushes the value into the component (`value:` on the leaf). Keys the
component does not know are ignored silently. That is deliberate: a configuration file may contain
more, or differently structured, data than any single component needs.

```smalltalk
MyServer new canopyMapping apply: (Canopy / #myServer).
```

## Tags

Every node has a set of tags. `importTree:tags:` tags every imported node; merging adds tags, it
never replaces them. Several sources can therefore share one tree, and each value still says where
it came from:

```smalltalk
tree importTree: '{ "one" : 1 }' tags: #( appA ).
tree importTree: '{ "one" : 2, "two" : 3 }' tags: #( appB ).
(tree / #one) tags.   "appA appB"
(tree / #two) tags.   "appB"
```

Plain `apply:` ignores tags. `apply:withTag:` applies only leaves carrying the tag, for example to
re-apply the configuration after a file reload without touching anything else:

```smalltalk
component apply: tree withTag: #config.
```

Domains and tags both express ownership: a domain at the coarse, structural level (a top-level
position), tags within a domain and interleaved.

## Labels

Every node can carry labels, and a node sees the labels of all its ancestors. The same walk up the
parents that produces the name produces the labels, and a label set closer to the value wins over
an inherited one. One label at the root reaches every metric in the image:

```smalltalk
Canopy instance labelAt: #stage put: 'production'.
```

## Metrics

### Value holders

An accessor has two ways to answer:

- `value` / `value:`: always the raw value. Configuration, `apply:` and the JSON view use these.
- `valueHolder`: the value wrapped in a holder. Only the exporter asks for it.

`asCanopyValue` wraps any object in a `CanopyValue`; a holder answers itself. A pragma method may
therefore answer either a raw value or a holder.

The exporter asks each holder for its readings with `readingsDo:`. A `CanopyValue` has none, a
`CanopyMetric` has one, a `CanopyMetricMap` has one per key. That is the whole export filter:
configuration values never reach the scrape, and nobody maintains a flag for it. A metric whose
value is `nil` has no readings either, so a number that is not known yet shows up as a gap instead
of `nil` or a misleading zero.

### Declared metrics

```smalltalk
MyServer >> openConnectionsCanopy
	<canopyValue: #openConnections>
	^ CanopyMetric new
		type: #gauge;
		description: 'Number of open connections';
		value: connections size

MyServer >> responsesCanopy
	<canopyValue: #httpResponses>
	^ CanopyMetricMap new
		type: #counter;
		description: 'Number of responses by status';
		labelName: #status;
		value: self responses   "a Dictionary: status code -> count"
```

`type:` is the Prometheus type, `#gauge` or `#counter`. A metric can carry labels its component
knows (`labelAt:put:`, e.g. the database a number belongs to); the tree adds the labels of its
nodes. Configured limits and measured values can live next to each other and be combined, for
example into a usage percentage.

### Runtime metrics

A value that no pragma declares is added on its branch with a block, which is evaluated at every
scrape:

```smalltalk
(Canopy /+ #myServer)
	gauge: #queueLength description: 'Jobs waiting' reading: [ queue size ];
	counter: #jobsDone description: 'Jobs finished' reading: [ doneCount ];
	gauge: #databaseSize label: #database description: 'Size per database'
		reading: [ self databaseSizes ].   "a Dictionary: database name -> size"
```

`metric:at:reading:` is the general form for any holder. Declaring the same key again replaces the
leaf. The lower-level building block is `CanopyAccessor reading: aBlock`, a leaf whose value is
computed by the block.

### Built-in metrics

`Canopy registerSystemMetrics` registers these under the domain `#pharo` (names as exported):

| Name | Type |
|---|---|
| `pharo_image_processesActive`, `pharo_image_processesTerminated` | gauge |
| `pharo_image_fileRegistrySize` | gauge |
| `pharo_virtualMachine_memorySize`, `_memoryEnd`, `_oldSpace`, `_oldSpaceEnd`, `_freeOldSpaceSize`, `_edenSpaceSize`, `_youngSpaceSize`, `_youngSpaceEnd`, `_extraVMMemory` | gauge |
| `pharo_virtualMachine_fullGCCount`, `_incrementalGCCount`, `_tenureCount` | counter |
| `pharo_virtualMachine_totalFullGCTime`, `_totalIncrementalGCTime` | gauge |
| `pharo_virtualMachine_maxExternalSemaphores` | gauge, also writable |
| `pharo_virtualMachine_externalObjects`, `_externalObjectTableSize` | gauge |

`registerImageMetrics` and `registerVirtualMachineMetrics` register the two halves separately.

`Canopy registerZincMetrics` subscribes `CanopyZincCounter` to the Zinc server's log events and
registers the domain `#zinc`:

| Name | Type |
|---|---|
| `zinc_httpRequests` | counter |
| `zinc_httpResponses{status="…"}` | counter, seeded with 0 for the common status codes |
| `zinc_duration` | gauge, a smoothed average request duration |

What is counted can be narrowed by path:

```smalltalk
CanopyZincCounter instance
	addIncludePrefix: '/api';       "count only these paths"
	addExcludePrefix: '/metrics'.   "and never the scrape itself"
```

Both registrations can run more than once; the Zinc subscription is made only once.
`CanopyZincCounter uninstall` removes it.

## Prometheus export

`CanopyMetricsHandler` is a Zinc handler that answers the Prometheus text format. Without further
configuration it exports the whole tree, unprefixed. With `addDomain:` it exports only the named
domains, optionally with a prefix. Each domain is resolved again on every request, so the values
are live and re-registrations are picked up.

```smalltalk
| handler |
handler := CanopyMetricsHandler new
	addDomain: #pharo;
	addDomain: #myServer prefix: 'apptive';
	yourself.
(ZnServer startOn: 9100) delegate: handler.
```

```
# HELP pharo_virtualMachine_memorySize The size of memory
# TYPE pharo_virtualMachine_memorySize gauge
pharo_virtualMachine_memorySize{stage="production"} 123456789 1759140000000
```

The metric name is the node's `fullKey`, preceded by the prefix if there is one. `HELP` and `TYPE`
are written only when there is at least one line. Labels are sorted by name and written without
braces when there are none. Every line carries a timestamp in milliseconds. A leaf that raises
while it is read is left out, and the rest of the scrape continues.

`CanopyPrometheusVisitor` can be used directly: `format: aNode` renders one subtree,
`addDomain:`/`addDomain:prefix:` followed by `export` renders several.

## Browsing and editing over HTTP

`CanopyBrowseHandler` exposes the tree as JSON. Path segments of the request are keys:

| Request | Result |
|---|---|
| `GET /myServer/httpServer` | the subtree as JSON |
| `PUT /myServer/httpServer/port` with `9090` | writes the leaf |
| `PUT /myServer/httpServer` with `{"port":9090}` | applies the object like a configuration (unknown keys are ignored) |
| unknown key, or a path through a leaf | 404 |
| a scalar sent to a branch | 400 |
| any other method | 405 |

`CanopyBrowseHtmlHandler` wraps it. Requests without `text/html` in `Accept` are passed through
unchanged. A browser gets a table per branch, with links into child branches and an editable field
with a Save button per leaf.

```smalltalk
Canopy registerSystemMetrics.
(ZnServer startOn: 8080) delegate: CanopyBrowseHtmlHandler new.
```

Both handlers default to `Canopy instance`; `root:` points them at another tree. None of the
handlers claims a route; mounting under a path prefix is the caller's job.

> **Warning:** a writable global value tree over HTTP has no authentication, validation or audit
> log in Canopy. Do not expose the browse handlers on a public interface without putting that in
> front of them.

## Tests and the singleton

A test that registers domains of its own should not reset the image's tree. In a server image that
tree is the one being served, and after `Canopy reset` the metrics endpoint answers with an empty
body. Use a temporary tree instead:

```smalltalk
Canopy useNewInstanceDuring: [
	Canopy registerDomainNamed: #test with: aNode.
	"…" ]
```

The previous tree is put back afterwards, even if the block fails.

## Errors

| Error | Cause |
|---|---|
| `NotFound` | `/` or `at:` with a key the branch does not have |
| `a value can not be traversed` | `/` on a leaf; use `@` to read its value |
| `this accessor has no read selector` / `… no write selector` | reading a write-only leaf, or writing a read-only one |
| `two canopy declarations read …` / `… write …` | two pragmas declare the same key in the same direction |
| `domain … is already registered` | `registerDomainNamed:with:` with a name that exists |
| `conflict` | a merge without defined meaning, see [Merge and apply](#merge-and-apply) |

## Development

The code is in [Tonel](https://github.com/pharo-vcs/tonel) format under `source/`. CI runs
[smalltalkCI](https://github.com/hpi-swa/smalltalkCI) through GitHub Actions on every pull request
and on pushes to `main`, with the configuration in `.smalltalk.ston`.

## License

MIT, see [LICENSE](LICENSE).
