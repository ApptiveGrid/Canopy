Class {
	#name : 'CanopyZincTestAnnouncement',
	#superclass : 'Object',
	#instVars : [
		'responseCode',
		'duration'
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
CanopyZincTestAnnouncement >> responseCode: aCode duration: aDuration [
	responseCode := aCode.
	duration := aDuration
]
