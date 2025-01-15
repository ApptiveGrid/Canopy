Class {
	#name : 'GlobValueHolder',
	#superclass : 'GlobNode',
	#instVars : [
		'value',
		'dependent'
	],
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'arithmetic' }
GlobValueHolder >> / aString [ 
	Error signal: 'a value can not be traversed'
]

{ #category : 'actions' }
GlobValueHolder >> merge: aGlobNode [ 
	value := aGlobNode value.
	tags addAll: aGlobNode tags
]

{ #category : 'as yet unclassified' }
GlobValueHolder >> mergeInto: aGlobValueHolder [ 
	self error: 'cponflict'
]

{ #category : 'printing' }
GlobValueHolder >> printOn: aStream [ 
	aStream << 'value: ' << value printString 
]

{ #category : 'enumerating' }
GlobValueHolder >> recursiveDo: aBlock [ 
	aBlock value: self 
]

{ #category : 'registry' }
GlobValueHolder >> register: aPTAccessor [ 
	value
		ifNotNil: [ aPTAccessor value: value ]
		ifNil: [ dependent := aPTAccessor ]
]

{ #category : 'accessing' }
GlobValueHolder >> tags: aCollection [ 
	tags ifNil: [ tags := Set new ].
	tags addAll: aCollection 
]

{ #category : 'evaluating' }
GlobValueHolder >> value [ 
	^ value 
]

{ #category : 'accessing' }
GlobValueHolder >> value: anObject [  
	value := anObject 
]
