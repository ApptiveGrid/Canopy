Class {
	#name : 'GlobalTreeAcc',
	#superclass : 'Object',
	#instVars : [
		'object',
		'selector'
	],
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'accessing' }
GlobalTreeAcc >> object: anObject [ 
	object := anObject 
]

{ #category : 'as yet unclassified' }
GlobalTreeAcc >> object: aSoilSetup selector: aString [ 
	self shouldBeImplemented.
]

{ #category : 'accessing' }
GlobalTreeAcc >> selector: aString [ 
	selector := aString 
]

{ #category : 'accessing' }
GlobalTreeAcc >> value: anObject [ 
	object perform: selector with: anObject 
]
