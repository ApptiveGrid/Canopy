Class {
	#name : 'CanopyComposedSubComponent',
	#superclass : 'Object',
	#instVars : [
		'value'
	],
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'accessing' }
CanopyComposedSubComponent >> value: anInteger [
	value := anInteger
]

{ #category : 'as yet unclassified' }
CanopyComposedSubComponent >> valueCanopy [
	<canopyValue: #value>
	^ CanopyMetric new
		type: #gauge;
		description: 'A sub-component value';
		value: value
]
