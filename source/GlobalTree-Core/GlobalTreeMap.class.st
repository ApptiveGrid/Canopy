Class {
	#name : 'GlobalTreeMap',
	#superclass : 'Object',
	#instVars : [
		'properties'
	],
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'adding' }
GlobalTreeMap >> add: anObject [ 
	self addLocal: anObject.
	self addNested: anObject.
]

{ #category : 'adding' }
GlobalTreeMap >> addLocal: anObject [ 
	| pragmas |
	pragmas := Pragma 
		allNamed: #globalTreeValue:type:
		from: anObject class 
		to: Object.
	(pragmas size > 0) ifTrue: [ 
		pragmas do: [ :pragma | 
			self 
				at: (pragma arguments first)
				put: (GlobalTreeAcc new 
					object: anObject;
					selector: pragma method selector) ] ].
]

{ #category : 'adding' }
GlobalTreeMap >> addNested: anObject [ 
	| pragmas |
	pragmas := Pragma 
		allNamed: #globalTreeMap
		from: anObject class 
		to: Object.
	(pragmas size = 1) ifTrue: [ 
		anObject perform: pragmas first selector asMutator with: self ]
]

{ #category : 'target resize' }
GlobalTreeMap >> apply: aGlobBranch [ 
	aGlobBranch keysAndValuesDo: [ :key : value |
		(value isKindOf: GlobBranch)
			ifTrue: [ (properties at: key) apply: value ]
			ifFalse: [ (properties at: key) value: value value ]
		 ]
]

{ #category : 'accessing' }
GlobalTreeMap >> at: aString put: anObject [ 
	properties 
		at: aString 
		put: anObject 
]

{ #category : 'accessing' }
GlobalTreeMap >> at: aString setupObject: anObject [ 
	(properties 
		at: aString 
		ifAbsentPut: [ GlobalTreeMap new ]) add: anObject
]

{ #category : 'initialization' }
GlobalTreeMap >> initialize [ 
	super initialize.
	properties := Dictionary new
]
