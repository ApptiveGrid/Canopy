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

{ #category : 'accessing' }
CanopyAccessor class >> handlesType: aString [
	^ (super handlesType: aString) or: [ aString = #accessor ]
]

{ #category : 'accessing' }
CanopyAccessor class >> type [
	^ #metric
]

{ #category : 'visiting' }
CanopyAccessor >> acceptCanopy: aVisitor [
	"Write-only accessors (no readSelector) contribute nothing to export/formatting -
	they have nothing to read and therefore nothing to export."
	^ readSelector ifNotNil: [ aVisitor visitMetric: self ]
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
