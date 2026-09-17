Class {
	#name : 'CanopyAccessor',
	#superclass : 'CanopyLeafNode',
	#instVars : [
		'object',
		'readSelector',
		'writeSelector'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'instance creation' }
CanopyAccessor class >> reading: aBlock [
	"A leaf whose value is worked out on the spot instead of being read off a component: the
	block is the object and evaluating it is the read. That is how a value nobody declared with
	a pragma gets into the tree - every runtime metric of the servers is built that way."
	^ self new
		object: aBlock;
		readSelector: #value;
		yourself
]

{ #category : 'visiting' }
CanopyAccessor >> acceptCanopy: aVisitor [
	"Write-only accessors (no readSelector) contribute nothing to export/formatting -
	they have nothing to read and therefore nothing to export."
	^ readSelector ifNotNil: [ aVisitor visitMetric: self ]
]

{ #category : 'converting' }
CanopyAccessor >> asRawValue [
	"A leaf that was only declared for writing has nothing to answer. Saying so with nil keeps a
	single write-only accessor from taking the whole JSON view of a tree down with it."
	^ readSelector ifNotNil: [ self value ]
]

{ #category : 'initialization' }
CanopyAccessor >> initializeFromPragma: aPragma [
	"The direction comes from the arity of the declaring method: one that takes a value can only
	write, one that answers a value can only read. Declaring the same direction twice for one key
	is an error rather than a silent overwrite."
	aPragma method numArgs = 0
		ifTrue: [
			readSelector ifNotNil: [
				^ self error: 'two canopy declarations read ' , aPragma arguments first asString ].
			readSelector := aPragma method selector ]
		ifFalse: [
			writeSelector ifNotNil: [
				^ self error: 'two canopy declarations write ' , aPragma arguments first asString ].
			writeSelector := aPragma method selector ]
]

{ #category : 'accessing' }
CanopyAccessor >> object: anObject [
	object := anObject
]

{ #category : 'printing' }
CanopyAccessor >> printOn: aStream [
	super printOn: aStream.
	readSelector ifNotNil: [
		aStream << '['.
		self value printOn: aStream.
		aStream << ']' ]
]

{ #category : 'accessing' }
CanopyAccessor >> readSelector: aSelector [
	readSelector := aSelector
]

{ #category : 'evaluating' }
CanopyAccessor >> value [
	"The raw value. Every reader outside the export path wants this one, so the holder stays
	invisible here."
	^ self valueHolder value
]

{ #category : 'accessing' }
CanopyAccessor >> value: anObject [
	"Unwrap on the way in, so the component's own write method keeps receiving a raw value
	and never has to know about holders."
	writeSelector ifNil: [ ^ self error: 'this accessor has no write selector' ].
	object perform: writeSelector asMutator with: anObject asCanopyValue value
]

{ #category : 'evaluating' }
CanopyAccessor >> valueHolder [
	"What the read selector answers, wrapped: a plain value becomes a CanopyValue, a holder
	answers itself. Only the export path asks for this."
	readSelector ifNil: [ ^ self error: 'this accessor has no read selector' ].
	^ (object perform: readSelector) asCanopyValue
]

{ #category : 'accessing' }
CanopyAccessor >> writeSelector: aSelector [
	writeSelector := aSelector
]
