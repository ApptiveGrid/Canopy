Class {
	#name : 'CanopyPrometheusVisitor',
	#superclass : 'CanopyVisitor',
	#instVars : [
		'stream',
		'exports',
		'currentPrefix'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'writing' }
CanopyPrometheusVisitor >> asMilliseconds: timestamp [
		^((timestamp offset: Duration zero) - DateAndTime unixEpoch) asMilliSeconds
]

{ #category : 'configuring' }
CanopyPrometheusVisitor >> addDomain: aNode [
	"Export the aNode subtree without a prefix - the metric names are written as-is
	(their own fullKey). See addDomain:prefix: for the prefixed variant."
	exports add: aNode -> nil
]

{ #category : 'configuring' }
CanopyPrometheusVisitor >> addDomain: aNode prefix: aString [
	"Export the aNode subtree, prepending aString and an underscore to every metric name
	(e.g. prefix: 'pharo' turns virtualMachine_memorySize into pharo_virtualMachine_memorySize).
	The prefix is purely an export concern - it lives here, never on the domain node."
	exports add: aNode -> aString
]

{ #category : 'as yet unclassified' }
CanopyPrometheusVisitor >> convertMetricName: aMetric [
	^ currentPrefix
		ifNil: [ aMetric fullKey ]
		ifNotNil: [ currentPrefix asString, '_', aMetric fullKey ]
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> export [
	"Format only the explicitly configured domains (see addDomain:/addDomain:prefix:),
	each with its optional prefix. Returns an empty string when nothing was configured.
	Contrast format:, which formats a single given object with no prefix."
	stream := WriteStream on: ''.
	exports do: [ :assoc |
		currentPrefix := assoc value.
		self visit: assoc key ].
	currentPrefix := nil.
	^ stream contents
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> format: anObject [
	stream := WriteStream on: ''.
	self visit: anObject.
	^ stream contents
]

{ #category : 'initialization' }
CanopyPrometheusVisitor >> initialize [
	super initialize.
	stream := WriteStream on: ''.
	exports := OrderedCollection new.
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> visitBranchNode: aCanopyBranchNode [ 
	self visitAll: aCanopyBranchNode nodes 
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> visitCell: aCanopyCell [
	"Config values share the tree with metrics but have nothing to export. Before this, a single
	config cell in an exported domain ended the whole scrape in a doesNotUnderstand."
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> visitMetric: aNode [
	"Ask the value what it contributes and write one line per reading. A value that is not a
	metric answers nothing, so nothing is written - not even the HELP and TYPE header. That is
	why a config value in an exported tree now costs no output instead of ending the scrape."
	| holder header |
	holder := aNode valueHolder.
	header := false.
	holder readingsDo: [ :labels :value |
		header ifFalse: [
			self writeHelpLine: aNode holder: holder.
			self writeTypeLine: aNode holder: holder.
			header := true ].
		self
			writeName: (self convertMetricName: aNode)
			value: value
			attributes: aNode labels , labels ]
]

{ #category : 'writing' }
CanopyPrometheusVisitor >> writeHelpLine: aNode holder: aMetric [
	stream
		nextPutAll: '# HELP ';
		nextPutAll: (self convertMetricName: aNode);
		nextPutAll: ' '.
	stream nextPutAll: (aMetric description ifNil: [ aNode key asString ]).
	stream nextPut: Character linefeed
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> writeName: aName value: aValue attributes: aDictionary [
	"Sorted by label name, and no braces at all when there are none. The order a Dictionary
	answers falls out of the key hashes - neither the declared nor the alphabetical one - and it
	shifts as soon as a label is added. Prometheus treats labels as a set and is indifferent to
	both; tests that compare the line as a string are not."
	stream nextPutAll: aName.
	aDictionary ifNotEmpty: [
		stream nextPut: ${.
		(aDictionary associations sorted: [ :a :b | a key asString <= b key asString ])
			do: [ :assoc |
				stream
					nextPutAll: assoc key;
					nextPutAll: '="';
					nextPutAll: assoc value asString;
					nextPutAll: '"' ]
			separatedBy: [ stream nextPut: $, ].
		stream nextPut: $} ].
	stream nextPut: Character space.
	stream nextPutAll: aValue asString.
	stream nextPut: Character space.
	stream nextPutAll: (self asMilliseconds: DateAndTime now) asString.
	stream nextPut: Character linefeed
]

{ #category : 'writing' }
CanopyPrometheusVisitor >> writeTypeLine: aNode holder: aMetric [
	stream
		nextPutAll: '# TYPE ';
		nextPutAll: (self convertMetricName: aNode);
		nextPutAll: ' ';
		nextPutAll: aMetric type;
		nextPut: Character linefeed
]
