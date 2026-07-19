Class {
	#name : 'CanopyRootTestObject',
	#superclass : 'Object',
	#instVars : [
		'one'
	],
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'accessing' }
CanopyRootTestObject >> one [
	<canopyValue: #one type: #accessor arguments: #()>
	^ one
]

{ #category : 'accessing' }
CanopyRootTestObject >> one: anObject [
	one := anObject
]
