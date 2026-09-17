Class {
	#name : 'CanopyMetricTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'as yet unclassified' }
CanopyMetricTest >> testAMetricAnswersOneReadingWithItsOwnLabels [
	| metric seen |
	metric := CanopyMetric new
		type: #gauge;
		description: 'The size of memory';
		value: 1024;
		yourself.
	metric labelAt: #database put: 'alpha'.
	seen := OrderedCollection new.
	metric readingsDo: [ :labels :value | seen add: labels -> value ].
	self assert: seen size equals: 1.
	self assert: seen first value equals: 1024.
	self assert: (seen first key at: #database) equals: 'alpha'
]

{ #category : 'as yet unclassified' }
CanopyMetricTest >> testAMetricIsAValueHolderAndAnswersItsValueRaw [
	"Everything that reads a leaf keeps seeing the bare number; only the export asks for more."
	| metric |
	metric := CanopyMetric new value: 1024; yourself.
	self assert: metric value equals: 1024.
	self assert: metric asCanopyValue identicalTo: metric
]

{ #category : 'as yet unclassified' }
CanopyMetricTest >> testAPlainValueAnswersNoReadings [
	"This is the export filter. A config value is not a metric, answers no reading and therefore
	never reaches the scrape endpoint - without anyone maintaining a flag or testing a class."
	| seen |
	seen := OrderedCollection new.
	42 asCanopyValue readingsDo: [ :labels :value | seen add: value ].
	self assert: seen isEmpty
]
