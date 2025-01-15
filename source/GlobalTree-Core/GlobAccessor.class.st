Class {
	#name : 'GlobAccessor',
	#superclass : 'Object',
	#instVars : [
		'object',
		'selector'
	],
	#category : 'GlobalTree-Core-Objects',
	#package : 'GlobalTree-Core',
	#tag : 'Objects'
}

{ #category : 'accessing' }
GlobAccessor >> object: anObject [ 
	object := anObject 
]

{ #category : 'accessing' }
GlobAccessor >> selector: aString [ 
	selector := aString 
]

{ #category : 'accessing' }
GlobAccessor >> value: anObject [
	object perform: selector asSymbol asMutator with: anObject  
]
