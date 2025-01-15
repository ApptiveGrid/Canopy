Class {
	#name : 'GlobNode',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'tags'
	],
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'accessing' }
GlobNode >> addTag: aString [ 
	tags add: aString 
]

{ #category : 'accessing' }
GlobNode >> addTags: aCollection [
	aCollection do: [ :each | 
		self addTag: each  ]
]

{ #category : 'initialization' }
GlobNode >> initialize [
	super initialize.
	tags := Set new 
]

{ #category : 'actions' }
GlobNode >> merge: aGlobBranch [ 
	aGlobBranch mergeInto: self 
]

{ #category : 'accessing' }
GlobNode >> parent: aPNode [
	parent := aPNode
]

{ #category : 'accessing' }
GlobNode >> tags: aCollection [ 
	tags := aCollection 
]
