Class {
	#name : 'CanopyMetric',
	#superclass : 'CanopyLeafNode',
	#instVars : [
		'object',
		'name',
		'description',
		'valueType',
		'selector'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'accessing' }
CanopyMetric class >> type [ 
	^ #metric
]

{ #category : 'visiting' }
CanopyMetric >> acceptCanopy: aVisitor [ 
	aVisitor visitMetric: self 
]

{ #category : 'accessing' }
CanopyMetric >> description [
	^ description
]

{ #category : 'testing' }
CanopyMetric >> hasDescription [
	^ description notNil
]

{ #category : 'initialization' }
CanopyMetric >> initializeFromPragma: aPragma [ 
	| args |
	args := aPragma arguments third.
	selector := aPragma method selector.
	name := aPragma arguments first.
	description := args first.
	valueType := args second.
	
]

{ #category : 'accessing' }
CanopyMetric >> object: anObject [
	object := anObject 
]

{ #category : 'printing' }
CanopyMetric >> printOn: aStream [ 
	super printOn: aStream .
	aStream << '['.
	self value printOn: aStream.
	aStream << ']' 
]

{ #category : 'evaluating' }
CanopyMetric >> value [ 
	^ object perform: selector 
]

{ #category : 'accessing' }
CanopyMetric >> value: anObject [ 
	self error: 'a metric cannot be written'
]

{ #category : 'accessing' }
CanopyMetric >> valueType [
	^ valueType
]
