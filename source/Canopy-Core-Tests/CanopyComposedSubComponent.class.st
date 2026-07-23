Class {
	#name : 'CanopyComposedSubComponent',
	#superclass : 'Object',
	#instVars : [
		'value'
	],
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'accessing' }
CanopyComposedSubComponent >> value: anInteger [
	value := anInteger
]

{ #category : 'as yet unclassified' }
CanopyComposedSubComponent >> valueCanopy [
	<canopyValue: #value type: #metric arguments: #('A sub-component value' gauge)>
	^ value
]
