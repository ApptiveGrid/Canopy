Class {
	#name : 'CanopyReadWriteLeafExampleTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'as yet unclassified' }
CanopyReadWriteLeafExampleTest >> testConfiguredLimitAndLiveUsageProduceExportedPercentage [
	"Leitbeispiel aus Canopy roadmap, Terminologie Accessor/Metric-Richtungsambiguitaet: ein
	konfiguriertes Memory-Limit (write Canopy -> component, ueber den #accessor-Pragma-Pfad)
	sitzt neben einem laufend erzeugten aktuell-genutzt-Wert (read component -> Canopy, ueber
	den #metric-Pfad) auf demselben Objekt, gebaut in einem einzigen Pragma-Reflection-Durchlauf
	- genau wofuer die Accessor/Metric-Vereinheitlichung (PR #19) gedacht war. Eine daraus
	abgeleitete Nutzungs-Prozentzahl wird genauso exportiert wie jede andere Metrik."
	| object tree output |
	object := CanopyMemoryLimitExampleObject new.
	object canopySetupFrom: '{ "memoryLimit": 1000 }'.
	object usedMemory: 250.
	tree := object canopyMapping.
	self assert: object memoryLimit equals: 1000.
	self assert: (tree / #usedMemory) value equals: 250.
	self assert: (tree / #usagePercentage) value equals: 25.
	output := CanopyPrometheusVisitor new format: tree.
	self assert: (output includesSubstring: 'usagePercentage{} 25 ')
]
