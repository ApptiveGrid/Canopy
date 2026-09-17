Class {
	#name : 'CanopyValueHolder',
	#superclass : 'Object',
	#instVars : [
		'value'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'instance creation' }
CanopyValueHolder class >> value: anObject [
	^ self new
		value: anObject;
		yourself
]

{ #category : 'converting' }
CanopyValueHolder >> asCanopyValue [
	"Already a holder, so the conversion is the identity - Object>>asCanopyValue wraps
	everything else. This is what lets a pragma method return either a raw value or a holder."
	^ self
]

{ #category : 'printing' }
CanopyValueHolder >> printOn: aStream [
	super printOn: aStream.
	aStream << '['.
	value printOn: aStream.
	aStream << ']'
]

{ #category : 'evaluating' }
CanopyValueHolder >> value [
	^ value
]

{ #category : 'accessing' }
CanopyValueHolder >> value: anObject [
	value := anObject
]
