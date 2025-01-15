Class {
	#name : 'GlobServer',
	#superclass : 'Object',
	#instVars : [
		'port'
	],
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'accessing' }
GlobServer >> port [

	^ port
]

{ #category : 'accessing' }
GlobServer >> port: anObject [

	port := anObject
]

{ #category : 'as yet unclassified' }
GlobServer >> setupConfiguration [ 
	self globalTreeBind: GlobalTree apptiveGrid / #httpServer keys: #( port ) 
]
