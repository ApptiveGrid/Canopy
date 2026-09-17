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
	^ settings
]

{ #category : 'accessing' }
CanopyDictionaryTestObject >> settings: aDictionary [
	settings := aDictionary
]

{ #category : 'canopy' }
CanopyDictionaryTestObject >> settingsCanopy [
	"The other direction at the same key, so the browse view shows the settings instead of null -
	a write-only declaration has nothing to answer."
	<canopyValue: #settings>
	^ self settings
]

{ #category : 'canopy' }
CanopyDictionaryTestObject >> settingsCanopy: aDictionary [
	"A whole subtree of the configuration arrives here as one plain Dictionary. Merging it into
	the live one rather than replacing it is this component's decision, not Canopy's."
	<canopyValue: #settings>
	settings addAll: aDictionary
]
