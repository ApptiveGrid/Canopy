Class {
	#name : 'CanopyValueHolder',
	#superclass : 'CanopyNode',
	#instVars : [
		'value',
		'dependent'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'arithmetic' }
CanopyValueHolder >> / aString [ 
	Error signal: 'a value can not be traversed'
]

{ #category : 'accessing' }
CanopyValueHolder >> inspectionLabel [ 
	^ self key , ' = ' , value printString 
]

{ #category : 'actions' }
CanopyValueHolder >> merge: aGlobNode [ 
	value := aGlobNode value.
	tags addAll: aGlobNode tags
]

{ #category : 'as yet unclassified' }
CanopyValueHolder >> mergeInto: aGlobValueHolder [ 
	self error: 'cponflict'
]

{ #category : 'printing' }
CanopyValueHolder >> printOn: aStream [ 
	super printOn: aStream .
	aStream << '['.
	value printOn: aStream.
	aStream << ']' 
]

{ #category : 'enumerating' }
CanopyValueHolder >> recursiveDo: aBlock [ 
	aBlock value: self 
]

{ #category : 'registry' }
CanopyValueHolder >> register: aPTAccessor [ 
	value
		ifNotNil: [ aPTAccessor value: value ]
		ifNil: [ dependent := aPTAccessor ]
]

{ #category : 'accessing' }
CanopyValueHolder >> tags: aCollection [ 
	tags ifNil: [ tags := Set new ].
	tags addAll: aCollection 
]

{ #category : 'evaluating' }
CanopyValueHolder >> value [ 
	^ value 
]

{ #category : 'accessing' }
CanopyValueHolder >> value: anObject [  
	value := anObject 
]
