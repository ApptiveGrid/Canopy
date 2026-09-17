Class {
	#name : 'CanopyMetricsVisitorTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'as yet unclassified' }
CanopyMetricsVisitorTest >> testConvertMetricNameUsesFullTreePathAcrossPlainBranches [
	"The group_name Prometheus convention (Canopy roadmap, Metriken aus pharo-metrics
	uebernehmen) must work even when an ancestor is a plain CanopyBranchNode, not a
	a plain CanopyBranchNode - #virtualMachine/#image (Canopy class>>registerSystemMetrics)
	are ordinary branches. fullKey walks the real parent chain, independent of the visitor -
	no longer relies on the now-removed CanopyPrometheusVisitor>>prefixes."
	| mapBranch metric root vmBranch output |
	mapBranch := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	metric := mapBranch / #memorySize.
	root := CanopyBranchNode new.
	vmBranch := CanopyBranchNode new.
	root at: #virtualMachine put: vmBranch.
	vmBranch at: #memorySize put: metric.
	output := CanopyPrometheusVisitor new format: root.
	self assert: (output includesSubstring: '# HELP virtualMachine_memorySize Memory size').
	self assert: (output includesSubstring: 'virtualMachine_memorySize')
]

{ #category : 'as yet unclassified' }
CanopyMetricsVisitorTest >> testExternalObjectMetricsHaveDistinctDescriptions [
	"Fixed 2026-07-21: externalObjectTableSizeCanopy/externalObjectsCanopy (and their
	pharo-metrics siblings, out of scope here per Norbert - only the Canopy pragmas in
	this repo matter, pharo-metrics is not loaded once Canopy replaces it) shared the exact
	same description despite measuring different things: total table size (including free
	slots) vs. count of currently registered (non-nil) objects."
	| metrics tableSize objects |
	[ ExternalSemaphoreTable canopyRegister.
	metrics := Canopy instance.
	tableSize := (metrics / #image / #externalObjectTableSize) valueHolder.
	objects := (metrics / #image / #externalObjects) valueHolder.
	self deny: tableSize description equals: objects description ]
		ensure: [ Canopy reset ]
]

{ #category : 'as yet unclassified' }
CanopyMetricsVisitorTest >> testAMapMetricProducesOneLinePerKeyUnderItsDeclaredLabel [
	"A map answers one reading per key, labelled with the name its own declaration carries -
	the visitor no longer knows anything about #status. The metric name stays the full
	underscore-joined tree path, see testConvertMetricNameUsesFullTreePath."
	| mapBranch metricMap root zinc output |
	mapBranch := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	metricMap := mapBranch / #responsesByStatus.
	root := CanopyBranchNode new.
	zinc := CanopyBranchNode new.
	root at: #zinc put: zinc.
	zinc at: #responsesByStatus put: metricMap.
	output := CanopyPrometheusVisitor new format: root.
	self assert: (output includesSubstring: '# HELP zinc_responsesByStatus Responses by status').
	self assert: (output includesSubstring: '# TYPE zinc_responsesByStatus gauge').
	self assert: (output includesSubstring: 'zinc_responsesByStatus{status="200"} 5 ').
	self assert: (output includesSubstring: 'zinc_responsesByStatus{status="404"} 2 ')
]

{ #category : 'as yet unclassified' }
CanopyMetricsVisitorTest >> testMapMetricReadingsCarryTheKeyAsALabel [
	| mapBranch seen |
	mapBranch := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	seen := Dictionary new.
	(mapBranch / #responsesByStatus) valueHolder readingsDo: [ :labels :count |
		seen at: (labels at: #status) put: count ].
	self assert: (seen at: 200) equals: 5.
	self assert: (seen at: 404) equals: 2
]

{ #category : 'export selection' }
CanopyMetricsVisitorTest >> memoryMetric [
	"A fresh, detached memorySize metric leaf, ready to be re-parented under a domain branch."
	^ (CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build) / #memorySize
]

{ #category : 'as yet unclassified' }
CanopyMetricsVisitorTest >> testLabelSetAtTheRootAppearsOnEveryMetricLine [
	"The stage label of the deployed servers hangs at the root and has to reach every line -
	pharo-metrics does it with attributes ^ parent attributes , attributes. Before labels walked
	the parent chain, a label set at the root simply never showed up in the output."
	| root vm output |
	root := CanopyBranchNode new.
	vm := CanopyBranchNode new.
	root at: #virtualMachine put: vm.
	vm at: #memorySize put: self memoryMetric.
	root labelAt: #stage put: 'production'.
	output := CanopyPrometheusVisitor new format: root.
	self assert: (output includesSubstring: 'virtualMachine_memorySize{stage="production"}')
]

{ #category : 'export selection' }
CanopyMetricsVisitorTest >> testExportMixesPharoPrefixedSystemDomainsAndBareApptiveGrid [
	"The three-domain leitszenario (Canopy roadmap, Option B): image and virtualMachine carry a
	pharo_ prefix, apptiveGrid stays bare - all in one configured export. Mirrors the old
	pharo-metrics layout (image/virtualMachine nested under a #pharo group, apptiveGrid top-level)
	without coupling the domain nodes to how they are exported."
	| root vm image ag output |
	root := CanopyBranchNode new.
	vm := CanopyBranchNode new.
	image := CanopyBranchNode new.
	ag := CanopyBranchNode new.
	root at: #virtualMachine put: vm.
	root at: #image put: image.
	root at: #apptiveGrid put: ag.
	vm at: #memorySize put: self memoryMetric.
	image at: #memorySize put: self memoryMetric.
	ag at: #memorySize put: self memoryMetric.
	output := CanopyPrometheusVisitor new
		addDomain: vm prefix: 'pharo';
		addDomain: image prefix: 'pharo';
		addDomain: ag;
		export.
	self assert: (output includesSubstring: 'pharo_virtualMachine_memorySize').
	self assert: (output includesSubstring: 'pharo_image_memorySize').
	self assert: (output includesSubstring: 'apptiveGrid_memorySize').
	self deny: (output includesSubstring: 'pharo_apptiveGrid')
]

{ #category : 'export selection' }
CanopyMetricsVisitorTest >> testExportOnlyIncludesConfiguredDomains [
	"Not every domain has to be exported (Norbert, 2026-07-27): only domains added via addDomain:
	appear; unconfigured siblings are silently skipped."
	| root vm ag output |
	root := CanopyBranchNode new.
	vm := CanopyBranchNode new.
	ag := CanopyBranchNode new.
	root at: #virtualMachine put: vm.
	root at: #apptiveGrid put: ag.
	vm at: #memorySize put: self memoryMetric.
	ag at: #memorySize put: self memoryMetric.
	output := CanopyPrometheusVisitor new addDomain: vm; export.
	self assert: (output includesSubstring: 'virtualMachine_memorySize').
	self deny: (output includesSubstring: 'apptiveGrid')
]

{ #category : 'export selection' }
CanopyMetricsVisitorTest >> testExportWithPrefixPrependsPrefixToMetricName [
	"addDomain:prefix: prepends prefix_ to every metric name of the domain. The bare,
	un-prefixed name must not also appear (the prefix replaces the top-level namespace)."
	| root vm output |
	root := CanopyBranchNode new.
	vm := CanopyBranchNode new.
	root at: #virtualMachine put: vm.
	vm at: #memorySize put: self memoryMetric.
	output := CanopyPrometheusVisitor new addDomain: vm prefix: 'pharo'; export.
	self assert: (output includesSubstring: 'pharo_virtualMachine_memorySize').
	self deny: (output includesSubstring: '# HELP virtualMachine_memorySize')
]

{ #category : 'export selection' }
CanopyMetricsVisitorTest >> testExportWithoutConfiguredDomainsIsEmpty [
	"A visitor with no configured domains exports nothing - format: is the unconfigured
	single-object path, export is the configured-selection path."
	self assert: CanopyPrometheusVisitor new export equals: ''
]

{ #category : 'export selection' }
CanopyMetricsVisitorTest >> testExportWithoutPrefixWritesNameAsIs [
	"apptiveGrid is written as-is (its own name is already the top segment), no extra prefix -
	the other half of Option B (Canopy roadmap)."
	| root ag output |
	root := CanopyBranchNode new.
	ag := CanopyBranchNode new.
	root at: #apptiveGrid put: ag.
	ag at: #memorySize put: self memoryMetric.
	output := CanopyPrometheusVisitor new addDomain: ag; export.
	self assert: (output includesSubstring: 'apptiveGrid_memorySize').
	self deny: (output includesSubstring: 'pharo')
]
