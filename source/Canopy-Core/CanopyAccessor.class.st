Class {
	#name : 'CanopyAccessor',
	#superclass : 'CanopyNode',
	#instVars : [
		'object',
		'selector'
	],
	#category : 'Canopy-Core-Objects',
	#package : 'Canopy-Core',
	#tag : 'Objects'
}

{ #category : 'accessing' }
CanopyAccessor >> inspectionLabel [ 
	^ self key 
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
