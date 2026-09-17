Class {
	#name : 'CanopyMetricMap',
	#superclass : 'CanopyMetric',
	#instVars : [
		'labelName'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'accessing' }
CanopyMetricMap >> labelName [
	^ labelName
]

{ #category : 'accessing' }
CanopyMetricMap >> labelName: aSymbol [
	"The label the keys of this map are written under. The declaration says it, not the
	exporter - which is how the hard-wired #status of the Zinc case left the general code."
	labelName := aSymbol
]

{ #category : 'enumerating' }
CanopyMetricMap >> readingsDo: aBlock [
	"One reading per key: the labels this metric carries, plus the key under the declared name."
	self value keysAndValuesDo: [ :key :each |
		aBlock
			value: (self labels copy
				at: labelName put: key;
				yourself)
			value: each ]
]
