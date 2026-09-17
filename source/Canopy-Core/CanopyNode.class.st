Class {
	#name : 'CanopyNode',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'tags',
		'labels'
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

{ #category : 'accessing' }
CanopyNode >> allKeys [
	^ parent
		ifNotNil: [ parent allKeys , { self key } ]
		ifNil: [ #() ]
]

{ #category : 'accessing' }
CanopyNode >> fullKey [
	^ '_' join: (self allKeys collect: [ :k | k asString ])
]

{ #category : 'initialization' }
CanopyNode >> initialize [
	super initialize.
	tags := Set new.
	labels := Dictionary new
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

{ #category : 'accessing' }
CanopyNode >> labelAt: aKey put: anObject [
	"Set a label on this node alone; every node below it sees it too, see labels."
	labels at: aKey put: anObject
]

{ #category : 'accessing' }
CanopyNode >> labels [
	"The labels of this node and of every node above it - the same walk up the parent chain
	that allKeys does for the name. A label set closer to the value wins over an inherited one,
	so a single stage label at the root reaches every line without being repeated anywhere."
	^ parent
		ifNotNil: [ parent labels , labels ]
		ifNil: [ labels ]
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
CanopyNode >> tags [
	^ tags
]

{ #category : 'accessing' }
CanopyNode >> tags: aCollection [ 
	tags := aCollection 
]
