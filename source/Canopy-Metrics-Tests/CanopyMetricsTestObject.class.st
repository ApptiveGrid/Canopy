Class {
	#name : 'CanopyMetricsTestObject',
	#superclass : 'Object',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'as yet unclassified' }
CanopyMetricsTestObject >> responsesByStatus [
	<canopyValue: #responsesByStatus type: #metricMap arguments: #('Responses by status' gauge)>
	^ Dictionary new at: 200 put: 5; at: 404 put: 2; yourself
]
