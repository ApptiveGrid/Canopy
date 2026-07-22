Class {
	#name : 'CanopyDictionaryTestObject',
	#superclass : 'Object',
	#instVars : [
		'settings'
	],
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'accessing' }
CanopyDictionaryTestObject >> settings [
	<canopyValue: #settings type: #dictionary arguments: #()>
	^ settings
]

{ #category : 'accessing' }
CanopyDictionaryTestObject >> settings: aDictionary [
	settings := aDictionary
]
