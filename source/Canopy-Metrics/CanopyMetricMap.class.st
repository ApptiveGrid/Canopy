Class {
	#name : 'CanopyMetricMap',
	#superclass : 'CanopyMetric',
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'accessing' }
CanopyMetricMap class >> type [
	^ #metricMap
]

{ #category : 'visiting' }
CanopyMetricMap >> acceptCanopy: aVisitor [
	aVisitor visitMetricMap: self
]

{ #category : 'accessing' }
CanopyMetricMap >> attributes [
	^ self properties
]

{ #category : 'accessing' }
CanopyMetricMap >> attributesAndValuesDo: aBlock [
	self value keysAndValuesDo: aBlock
]
