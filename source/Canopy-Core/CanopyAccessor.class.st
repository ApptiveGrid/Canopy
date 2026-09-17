Class {
	#name : 'CanopyAccessor',
	#superclass : 'CanopyLeafNode',
	#instVars : [
		'object',
		'readSelector',
		'writeSelector',
		'name',
		'description',
		'valueType'
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
	they are not metrics, silently skipped rather than crashing on nil name/description."
	^ readSelector ifNotNil: [ aVisitor visitMetric: self ]
]

{ #category : 'accessing' }
CanopyAccessor >> description [
	^ description
]

{ #category : 'testing' }
CanopyAccessor >> hasDescription [
	^ description notNil
]

{ #category : 'initialization' }
CanopyAccessor >> initializeFromPragma: aPragma [
	| args |
	(aPragma arguments second = #accessor)
		ifTrue: [ writeSelector := aPragma method selector ]
		ifFalse: [
			args := aPragma arguments third.
			readSelector := aPragma method selector.
			name := aPragma arguments first.
			args ifNotEmpty: [
				description := args first.
				valueType := args second ] ]
]

{ #category : 'accessing' }
CanopyAccessor >> name [
	^ name
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
CanopyAccessor >> valueType [
	^ valueType
]

{ #category : 'accessing' }
CanopyAccessor >> writeSelector: aSelector [
	writeSelector := aSelector
]
