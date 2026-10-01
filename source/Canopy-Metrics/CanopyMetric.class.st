Class {
	#name : 'CanopyMetric',
	#superclass : 'CanopyValueHolder',
	#instVars : [
		'type'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'enumerating' }
CanopyMetric >> readingsDo: aBlock [
	"One reading: the labels this metric knows itself, and its value. Whatever the tree adds is
	merged in by the export, which is the only place that knows both sides.

	None when there is no value. A number that is not known yet - not counted since the image
	started, not read because what it is read from is closed - is a gap in the series, and
	writing it would put the word nil on the scrape, or a zero that says something is known."
	self value ifNil: [ ^ self ].
	aBlock value: labels value: self value
]

{ #category : 'accessing' }
CanopyMetric >> type [
	"The Prometheus metric type, gauge or counter - what the number means over time."
	^ type
]

{ #category : 'accessing' }
CanopyMetric >> type: aSymbol [
	type := aSymbol
]
