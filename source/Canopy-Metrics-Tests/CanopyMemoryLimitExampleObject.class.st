Class {
	#name : 'CanopyMemoryLimitExampleObject',
	#superclass : 'Object',
	#instVars : [
		'memoryLimit',
		'usedMemory'
	],
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'accessing' }
CanopyMemoryLimitExampleObject >> memoryLimit [
	^ memoryLimit
]

{ #category : 'accessing' }
CanopyMemoryLimitExampleObject >> memoryLimit: anInteger [
	memoryLimit := anInteger
]

{ #category : 'canopy' }
CanopyMemoryLimitExampleObject >> memoryLimitCanopy: anInteger [
	"The configured half of the example: a one-argument projection that hands the value to the
	domain setter. The derived percentage below is the metric half."
	<canopyValue: #memoryLimit>
	self memoryLimit: anInteger
]

{ #category : 'as yet unclassified' }
CanopyMemoryLimitExampleObject >> usagePercentageCanopy [
	<canopyValue: #usagePercentage>
	^ CanopyMetric new
		type: #gauge;
		description: 'Percentage of the configured memory limit currently in use';
		value: (usedMemory / memoryLimit) * 100
]

{ #category : 'accessing' }
CanopyMemoryLimitExampleObject >> usedMemory: anInteger [
	usedMemory := anInteger
]

{ #category : 'as yet unclassified' }
CanopyMemoryLimitExampleObject >> usedMemoryCanopy [
	<canopyValue: #usedMemory>
	^ CanopyMetric new
		type: #gauge;
		description: 'Currently used memory';
		value: usedMemory
]
