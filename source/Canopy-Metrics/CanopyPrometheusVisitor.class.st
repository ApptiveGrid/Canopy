Class {
	#name : 'CanopyPrometheusVisitor',
	#superclass : 'CanopyVisitor',
	#instVars : [
		'stream',
		'prefixes'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'writing' }
CanopyPrometheusVisitor >> asMilliseconds: timestamp [
		^((timestamp offset: Duration zero) - DateAndTime unixEpoch) asMilliSeconds
]

{ #category : 'as yet unclassified' }
CanopyPrometheusVisitor >> convertMetricName: aMetric [
	^ aMetric "fullKey" key

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
	prefixes := OrderedCollection new
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
	| metrics |
	prefixes add: aMetricGroup name.
	metrics := self visitAll: aMetricGroup metrics.
	prefixes removeLast.
	^ metrics
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
