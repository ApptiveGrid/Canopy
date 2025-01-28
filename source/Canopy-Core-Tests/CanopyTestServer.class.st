Class {
	#name : 'CanopyTestServer',
	#superclass : 'Object',
	#instVars : [
		'port'
	],
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'accessing' }
CanopyTestServer >> port [

	^ port
]

{ #category : 'accessing' }
CanopyTestServer >> port: anObject [

	port := anObject
]

{ #category : 'as yet unclassified' }
CanopyTestServer >> setupConfiguration [ 
	self canopyBind: Canopy apptiveGrid / #httpServer keys: #( port ) 
]
