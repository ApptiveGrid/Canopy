Class {
	#name : 'CanopyNode',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'tags',
		'properties'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'accessing' }
CanopyNode >> addTag: aString [ 
	tags add: aString 
]

{ #category : 'accessing' }
CanopyNode >> addTags: aCollection [
	aCollection do: [ :each | 
		self addTag: each  ]
]

{ #category : 'initialization' }
CanopyNode >> initialize [
	super initialize.
	tags := Set new.
	properties := Dictionary new 
]

{ #category : 'accessing' }
CanopyNode >> inspectionKey [
	self subclassResponsibility 
]

{ #category : 'accessing' }
CanopyNode >> inspectionValue [
	self subclassResponsibility 
]

{ #category : 'accessing' }
CanopyNode >> key [
	^ parent 
		ifNotNil: [ parent keyOf: self ]
		ifNil: [ '/' ]
]

{ #category : 'actions' }
CanopyNode >> merge: aGlobBranch [ 
	aGlobBranch mergeInto: self 
]

{ #category : 'accessing' }
CanopyNode >> parent: aPNode [
	parent := aPNode
]

{ #category : 'printing' }
CanopyNode >> printOn: aStream [ 
	parent ifNil: [  aStream << '/'. ^ self  ].
	self printPathOn: aStream 
]

{ #category : 'printing' }
CanopyNode >> printPathOn: aStream [ 
	parent ifNil: [^ self ].
	parent printPathOn: aStream.
	aStream << '/'.
	aStream << (parent keyOf: self)
]

{ #category : 'accessing' }
CanopyNode >> properties [ 
	^ properties 
]

{ #category : 'accessing' }
CanopyNode >> tags [
	^ tags
]

{ #category : 'accessing' }
CanopyNode >> tags: aCollection [ 
	tags := aCollection 
]
