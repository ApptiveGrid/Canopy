Class {
	#name : 'CanopyZincCounter',
	#superclass : 'Object',
	#instVars : [
		'requests',
		'responses',
		'duration',
		'registration'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

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
	<canopyValue: #duration type: #metric arguments: #('Average duration of requests' gauge)>
	^ self duration
]

{ #category : 'counting' }
CanopyZincCounter >> handleAnnouncement: anAnnouncement [
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
	responses := Dictionary new
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
	<canopyValue: #httpRequests type: #metric arguments: #('Number of requests' counter)>
	^ self requests
]

{ #category : 'accessing' }
CanopyZincCounter >> responses [
	^ responses
]

{ #category : 'as yet unclassified' }
CanopyZincCounter >> responsesCanopy [
	<canopyValue: #httpResponses type: #metricMap arguments: #('Number of responses by status' counter)>
	^ self responses
]

{ #category : 'installing' }
CanopyZincCounter >> uninstall [
	ZnLogEvent announcer unsubscribe: self
]
