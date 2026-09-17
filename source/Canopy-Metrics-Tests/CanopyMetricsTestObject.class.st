Class {
	#name : 'CanopyMetricsTestObject',
	#superclass : 'Object',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'as yet unclassified' }
CanopyMetricsTestObject >> memorySize [
	<canopyValue: #memorySize>
	^ CanopyMetric new
		type: #gauge;
		description: 'Memory size';
		value: 1024
]

{ #category : 'as yet unclassified' }
CanopyMetricsTestObject >> responsesByStatus [
	<canopyValue: #responsesByStatus>
	^ CanopyMetricMap new
		type: #gauge;
		description: 'Responses by status';
		labelName: #status;
		value: (Dictionary new at: 200 put: 5; at: 404 put: 2; yourself)
]
