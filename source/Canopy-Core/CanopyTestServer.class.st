Class {
	#name : 'CanopyTestServer',
	#superclass : 'Object',
	#instVars : [
		'port'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
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
	self canopyBind: CanopyTree apptiveGrid / #httpServer keys: #( port ) 
]
