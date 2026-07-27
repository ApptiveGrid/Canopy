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
CanopyPrometheusVisitor >> visitMetric: aMetricGroup [ 
	self writeHelpLine: aMetricGroup.
	self writeTypeLine: aMetricGroup.
	self writeMetric: aMetricGroup 
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> visitMetricGroup: aMetricGroup [ 
	^ self visitAll: aMetricGroup metrics
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> visitMetricMap: aMetricMap [
	self writeHelpLine: aMetricMap.
	self writeTypeLine: aMetricMap.
	aMetricMap attributesAndValuesDo: [ :attribute :value |
		self 
			writeName: (self convertMetricName: aMetricMap)
			value: value 
			attributes: aMetricMap attributes, ({ #status -> attribute } asDictionary)  ]
]

{ #category : 'writing' }
CanopyPrometheusVisitor >> writeHelpLine: aMetric [
	stream 
		nextPutAll: '# HELP ';
		nextPutAll: (self convertMetricName: aMetric);
		nextPutAll: ' '.
	stream nextPutAll: (aMetric hasDescription 
		ifTrue: [ aMetric description ]
		ifFalse: [ aMetric name ]).
	stream nextPut: Character linefeed
]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> writeMetric: aMetric [ 
	self 
		writeName: (self convertMetricName: aMetric) 
		value: aMetric value
		attributes: aMetric properties

]

{ #category : 'visiting' }
CanopyPrometheusVisitor >> writeName: aName value: aValue attributes: aDictionary [
	stream nextPutAll: aName.
	aDictionary notNil ifTrue: [ 
		stream nextPut: ${.
		aDictionary associations
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
CanopyPrometheusVisitor >> writeTypeLine: aMetric [ 
	stream 
		nextPutAll: '# TYPE ';
		nextPutAll: (self convertMetricName: aMetric);
		nextPutAll: ' ';
		nextPutAll: aMetric valueType;
		nextPut: Character linefeed
]
