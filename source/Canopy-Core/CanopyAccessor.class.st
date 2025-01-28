Class {
	#name : 'CanopyAccessor',
	#superclass : 'CanopyLeafNode',
	#instVars : [
		'object',
		'selector'
	],
	#category : 'Canopy-Core-Objects',
	#package : 'Canopy-Core',
	#tag : 'Objects'
}

{ #category : 'accessing' }
CanopyAccessor class >> type [ 
	^ #accessor
]

{ #category : 'initialization' }
CanopyAccessor >> initializeFromPragma: aPragma [ 
	self halt.
]

{ #category : 'accessing' }
CanopyAccessor >> object: anObject [ 
	object := anObject 
]

{ #category : 'accessing' }
CanopyAccessor >> selector: aString [ 
	selector := aString 
]

{ #category : 'accessing' }
CanopyAccessor >> value: anObject [
	object 
		perform: selector asSymbol asMutator 
		with: anObject  
]
