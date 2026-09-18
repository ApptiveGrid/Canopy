Class {
	#name : 'CanopyZincCounter',
	#superclass : 'Object',
	#instVars : [
		'requests',
		'responses',
		'duration',
		'registration',
		'includePrefixes',
		'excludePrefixes'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'installing' }
CanopyZincCounter class >> canopyRegister [
	self install.
	^ Canopy registerDomainNamed: #zinc with: (CanopyMappingBuilder new object: self instance; map: CanopyBranchNode new; build)
]

{ #category : 'installing' }
CanopyZincCounter class >> install [
	^ self instance install
]

{ #category : 'accessing' }
CanopyZincCounter class >> instance [
	^ instance ifNil: [ instance := self new ]
]

{ #category : 'initialization' }
CanopyZincCounter class >> reset [
	instance := nil
]

{ #category : 'installing' }
CanopyZincCounter class >> uninstall [
	^ self instance uninstall
]

{ #category : 'configuring' }
CanopyZincCounter >> addExcludePrefix: aString [
	"Do not count requests to this path. The scrape endpoint itself is the obvious candidate -
	left alone, a counter of HTTP requests counts the requests that read it."
	excludePrefixes add: aString
]

{ #category : 'configuring' }
CanopyZincCounter >> addIncludePrefix: aString [
	"Count only requests to this path. As soon as one is named, everything else is ignored -
	the deployed servers narrow the count to '/api' this way."
	includePrefixes add: aString
]

{ #category : 'counting' }
CanopyZincCounter >> adjustDuration: aDuration [
	duration ifNil: [ ^ duration := aDuration ].
	duration := (((99 * duration) + aDuration) / 100) asInteger
]

{ #category : 'accessing' }
CanopyZincCounter >> duration [
	^ duration
]

{ #category : 'as yet unclassified' }
CanopyZincCounter >> durationCanopy [
	<canopyValue: #duration>
	^ CanopyMetric new
		type: #gauge;
		description: 'Average duration of requests';
		value: self duration
]

{ #category : 'counting' }
CanopyZincCounter >> countsRequestTo: aUrl [
	"Named prefixes narrow what is counted, excluded ones drop out of whatever is left. Both
	lists are honoured; with neither, everything counts."
	| pfad |
	pfad := aUrl pathPrintString.
	(excludePrefixes anySatisfy: [ :each | pfad beginsWith: each ]) ifTrue: [ ^ false ].
	includePrefixes ifEmpty: [ ^ true ].
	^ includePrefixes anySatisfy: [ :each | pfad beginsWith: each ]
]

{ #category : 'counting' }
CanopyZincCounter >> handleAnnouncement: anAnnouncement [
	(self countsRequestTo: anAnnouncement url) ifFalse: [ ^ self ].
	self increaseRequests.
	self increaseStatusCode: anAnnouncement responseCode.
	self adjustDuration: anAnnouncement duration
]

{ #category : 'counting' }
CanopyZincCounter >> increaseRequests [
	requests := requests + 1
]

{ #category : 'counting' }
CanopyZincCounter >> increaseStatusCode: statusCode [
	| count |
	count := responses at: statusCode ifAbsent: [ 0 ].
	responses at: statusCode put: count + 1
]

{ #category : 'initialization' }
CanopyZincCounter >> initialize [
	super initialize.
	requests := 0.
	duration := 0.
	responses := Dictionary new.
	includePrefixes := OrderedCollection new.
	excludePrefixes := OrderedCollection new.
	self initializeResponses
]

{ #category : 'initialization' }
CanopyZincCounter >> initializeResponses [
	"Seed the status codes the servers actually answer, so their series exist from the first
	scrape instead of appearing out of nowhere with the first response of that kind. Same list
	as pharo-metrics seeds today - a counter that starts at zero reads differently from one that
	starts existing halfway through the day."
	#( 200 201 202 204 301 302 400 401 403 404 405 500 502 503 504 ) do: [ :code |
		responses at: code put: 0 ]
]

{ #category : 'installing' }
CanopyZincCounter >> install [
	registration := ZnLogEvent announcer
		when: ZnSimplifiedServerTransactionEvent
		do: [ :ann | self handleAnnouncement: ann ]
		for: self
]

{ #category : 'accessing' }
CanopyZincCounter >> requests [
	^ requests
]

{ #category : 'as yet unclassified' }
CanopyZincCounter >> requestsCanopy [
	<canopyValue: #httpRequests>
	^ CanopyMetric new
		type: #counter;
		description: 'Number of requests';
		value: self requests
]

{ #category : 'accessing' }
CanopyZincCounter >> responses [
	^ responses
]

{ #category : 'as yet unclassified' }
CanopyZincCounter >> responsesCanopy [
	<canopyValue: #httpResponses>
	^ CanopyMetricMap new
		type: #counter;
		description: 'Number of responses by status';
		labelName: #status;
		value: self responses
]

{ #category : 'installing' }
CanopyZincCounter >> uninstall [
	ZnLogEvent announcer unsubscribe: self
]
