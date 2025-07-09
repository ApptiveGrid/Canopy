Class {
	#name : 'CanopyVisitor',
	#superclass : 'Object',
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'visiting' }
CanopyVisitor >> visit: anObject [
	anObject acceptCanopy: self 
]

{ #category : 'visiting' }
CanopyVisitor >> visitAll: aCollection [ 
	aCollection do: [ :each |
		self visit: each ]
]
