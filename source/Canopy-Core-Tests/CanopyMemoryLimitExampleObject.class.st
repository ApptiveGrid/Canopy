Class {
	#name : 'CanopyMemoryLimitExampleObject',
	#superclass : 'Object',
	#instVars : [
		'memoryLimit',
		'usedMemory'
	],
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'accessing' }
CanopyMemoryLimitExampleObject >> memoryLimit [
	<canopyValue: #memoryLimit type: #accessor arguments: #()>
	^ memoryLimit
]

{ #category : 'accessing' }
CanopyMemoryLimitExampleObject >> memoryLimit: anInteger [
	memoryLimit := anInteger
]

{ #category : 'as yet unclassified' }
CanopyMemoryLimitExampleObject >> usagePercentageCanopy [
	<canopyValue: #usagePercentage type: #metric arguments: #('Percentage of the configured memory limit currently in use' gauge)>
	^ (usedMemory / memoryLimit) * 100
]

{ #category : 'accessing' }
CanopyMemoryLimitExampleObject >> usedMemory: anInteger [
	usedMemory := anInteger
]

{ #category : 'as yet unclassified' }
CanopyMemoryLimitExampleObject >> usedMemoryCanopy [
	<canopyValue: #usedMemory type: #metric arguments: #('Currently used memory' gauge)>
	^ usedMemory
]
