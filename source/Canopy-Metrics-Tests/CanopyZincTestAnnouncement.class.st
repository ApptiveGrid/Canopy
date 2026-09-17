Class {
	#name : 'CanopyZincTestAnnouncement',
	#superclass : 'Object',
	#instVars : [
		'responseCode',
		'duration',
		'url'
	],
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'accessing' }
CanopyZincTestAnnouncement >> duration [
	^ duration
]

{ #category : 'accessing' }
CanopyZincTestAnnouncement >> responseCode [
	^ responseCode
]

{ #category : 'accessing' }
CanopyZincTestAnnouncement >> url [
	"Defaults to a path the deployed servers count, so a test that does not care about filtering
	does not have to say anything about it."
	^ url ifNil: [ '/api/grids' asZnUrl ]
]

{ #category : 'accessing' }
CanopyZincTestAnnouncement >> url: aString [
	url := aString asZnUrl
]

{ #category : 'accessing' }
CanopyZincTestAnnouncement >> responseCode: aCode duration: aDuration [
	responseCode := aCode.
	duration := aDuration
]
