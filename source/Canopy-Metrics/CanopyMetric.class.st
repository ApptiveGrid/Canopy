Class {
	#name : 'CanopyMetric',
	#superclass : 'CanopyValueHolder',
	#instVars : [
		'type',
		'description',
		'labels'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'accessing' }
CanopyMetric >> description [
	^ description
]

{ #category : 'accessing' }
CanopyMetric >> description: aString [
	description := aString
]

{ #category : 'initialization' }
CanopyMetric >> initialize [
	super initialize.
	labels := Dictionary new
]

{ #category : 'accessing' }
CanopyMetric >> labelAt: aKey put: anObject [
	"A label the component itself knows, as opposed to one the tree carries - the stage of a
	deployment hangs at the root, the database a number belongs to is known here."
	labels at: aKey put: anObject
]

{ #category : 'accessing' }
CanopyMetric >> labels [
	^ labels
]

{ #category : 'enumerating' }
CanopyMetric >> readingsDo: aBlock [
	"One reading: the labels this metric knows itself, and its value. Whatever the tree adds is
	merged in by the export, which is the only place that knows both sides."
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
