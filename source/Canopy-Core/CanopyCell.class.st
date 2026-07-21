Class {
	#name : 'CanopyCell',
	#superclass : 'CanopyLeafNode',
	#instVars : [
		'value',
		'dependents'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'accessing' }
CanopyCell class >> type [ 
	^ #value
]

{ #category : 'initialization' }
CanopyCell >> initialize [
	super initialize.
	dependents := OrderedCollection new
]

{ #category : 'actions' }
CanopyCell >> merge: aGlobNode [
	(aGlobNode isKindOf: CanopyCell) ifFalse: [ ^ self error: 'conflict' ].
	self value: aGlobNode value.
	tags addAll: aGlobNode tags
]

{ #category : 'as yet unclassified' }
CanopyCell >> mergeInto: aGlobValueHolder [ 
	self error: 'conflict'
]

{ #category : 'printing' }
CanopyCell >> printOn: aStream [ 
	super printOn: aStream .
	aStream << '['.
	value printOn: aStream.
	aStream << ']' 
]

{ #category : 'registry' }
CanopyCell >> register: aPTAccessor [
	dependents add: aPTAccessor.
	value ifNotNil: [ aPTAccessor value: value ]
]

{ #category : 'accessing' }
CanopyCell >> tags: aCollection [ 
	tags ifNil: [ tags := Set new ].
	tags addAll: aCollection 
]

{ #category : 'evaluating' }
CanopyCell >> value [ 
	^ value 
]

{ #category : 'accessing' }
CanopyCell >> value: anObject [
	value := anObject.
	dependents do: [ :each | each value: anObject ]
]
