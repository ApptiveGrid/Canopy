Class {
	#name : 'CanopyValueHolder',
	#superclass : 'Object',
	#instVars : [
		'value',
		'description',
		'labels'
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

{ #category : 'accessing' }
CanopyValueHolder >> description [
	"What the component itself says this value is for. A description on the node wins over
	this one - see CanopyNode>>description - so this is the fallback a component brings along."
	^ description
]

{ #category : 'accessing' }
CanopyValueHolder >> description: aString [
	description := aString
]

{ #category : 'initialization' }
CanopyValueHolder >> initialize [
	super initialize.
	labels := Dictionary new
]

{ #category : 'accessing' }
CanopyValueHolder >> labelAt: aKey put: anObject [
	"A label the component itself knows, as opposed to one the tree carries - the stage of a
	deployment hangs at the root, the database a number belongs to is known here."
	labels at: aKey put: anObject
]

{ #category : 'accessing' }
CanopyValueHolder >> labels [
	^ labels
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
