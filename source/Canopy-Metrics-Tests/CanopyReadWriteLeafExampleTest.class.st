Class {
	#name : 'CanopyReadWriteLeafExampleTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'as yet unclassified' }
CanopyReadWriteLeafExampleTest >> testComposedInstanceRegistersAsDomainViaCanopyBranch [
	"Antwort auf die Instanz-basierte Haelfte der Registrierungsmechanismus-Frage (siehe
	Canopy backlog, Registrierungsmechanismus): eine komponierte Instanz baut ueber ihre
	eigene <canopyBranch>-Methode eine komponierte Struktur aus mehreren Sub-Komponenten,
	die per canopyMapping + registerDomainNamed:with: als eigene Domain in Canopy landet -
	kein neuer Mechanismus noetig, canopyBranch war schon da (bisher nur an Dictionary
	demonstriert, siehe Canopy doc). fullKey loest auch ueber zwei Verschachtelungsebenen
	korrekt auf (myApp_componentA_value)."
	| app output |
	[ app := CanopyComposedAppExample new.
	app componentA value: 10.
	app componentB value: 20.
	Canopy registerDomainNamed: #myApp with: app canopyMapping.
	self assert: (Canopy / #myApp / #componentA / #value) value equals: 10.
	self assert: (Canopy / #myApp / #componentB / #value) value equals: 20.
	output := CanopyPrometheusVisitor new format: Canopy instance.
	self assert: (output includesSubstring: 'myApp_componentA_value{} 10 ').
	self assert: (output includesSubstring: 'myApp_componentB_value{} 20 ') ]
		ensure: [ Canopy reset ]
]

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
