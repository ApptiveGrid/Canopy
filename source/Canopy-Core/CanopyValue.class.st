Class {
	#name : 'CanopyValue',
	#superclass : 'CanopyLeafNode',
	#instVars : [
		'value',
		'dependent'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'accessing' }
CanopyValue class >> type [ 
	^ #value
]

{ #category : 'actions' }
CanopyValue >> merge: aGlobNode [ 
	value := aGlobNode value.
	tags addAll: aGlobNode tags
]

{ #category : 'as yet unclassified' }
CanopyValue >> mergeInto: aGlobValueHolder [ 
	self error: 'cponflict'
]

{ #category : 'printing' }
CanopyValue >> printOn: aStream [ 
	super printOn: aStream .
	aStream << '['.
	value printOn: aStream.
	aStream << ']' 
]

{ #category : 'registry' }
CanopyValue >> register: aPTAccessor [ 
	value
		ifNotNil: [ aPTAccessor value: value ]
		ifNil: [ dependent := aPTAccessor ]
]

{ #category : 'accessing' }
CanopyValue >> tags: aCollection [ 
	tags ifNil: [ tags := Set new ].
	tags addAll: aCollection 
]

{ #category : 'evaluating' }
CanopyValue >> value [ 
	^ value 
]

{ #category : 'accessing' }
CanopyValue >> value: anObject [  
	value := anObject 
]
