Class {
	#name : 'CanopyMetricGroup',
	#superclass : 'CanopyBranchNode',
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'visiting' }
CanopyMetricGroup >> acceptCanopy: aVisitor [
	aVisitor visitMetricGroup: self
]

{ #category : 'accessing' }
CanopyMetricGroup >> metrics [
	^ self nodes values
]

{ #category : 'accessing' }
CanopyMetricGroup >> name [
	^ self key
]
