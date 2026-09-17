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

{ #category : 'enumerating' }
CanopyValueHolder >> readingsDo: aBlock [
	"Enumerate what this value contributes to an export, as labels and a number. A plain value
	contributes nothing, so this does nothing - and that is the whole export filter: the exporter
	asks every holder and writes what it gets back, without testing a single class."
]

{ #category : 'evaluating' }
CanopyValueHolder >> value [
	^ value
]

{ #category : 'accessing' }
CanopyValueHolder >> value: anObject [
	value := anObject
]
