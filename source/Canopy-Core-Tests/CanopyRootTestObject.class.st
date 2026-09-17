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
	^ one
]

{ #category : 'accessing' }
CanopyRootTestObject >> one: anObject [
	one := anObject
]

{ #category : 'canopy' }
CanopyRootTestObject >> oneCanopy [
	"Both directions at one key, which is what two declarations on one key are for: the unary
	method reads, the one-argument method writes, and they become a single leaf."
	<canopyValue: #one>
	^ self one
]

{ #category : 'canopy' }
CanopyRootTestObject >> oneCanopy: anObject [
	<canopyValue: #one>
	self one: anObject
]
