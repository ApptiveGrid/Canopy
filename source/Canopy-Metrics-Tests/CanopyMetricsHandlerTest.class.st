Class {
	#name : 'CanopyMetricsHandlerTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'tests' }
CanopyMetricsHandlerTest >> testHandleRequestReturnsPrometheusFormattedCanopyTree [
	"CanopyMetricsHandler mirrors pharo-metrics' MetricsHandler as a plain Zinc handleRequest: -
	no HOP dependency, mountable anywhere (Canopy roadmap, HTTP-Scrape-Endpoint)."
	| mapping response |
	mapping := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	[ Canopy instance registerDomainNamed: #testMetrics with: mapping.
	response := CanopyMetricsHandler new handleRequest: nil.
	self assert: response isSuccess.
	self assert: response contentType equals: ZnMimeType textPlain setCharSetUTF8.
	self assert: (response entity contents includesSubstring: 'testMetrics_memorySize')
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyMetricsHandlerTest >> testHandleRequestWithoutConfigExportsAllRegisteredDomains [
	"Default (no addDomain: configured): the whole Canopy tree is exported, every domain,
	unprefixed - unchanged from the original handler behavior (Norbert, 2026-07-27)."
	| alpha beta response body |
	alpha := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	beta := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	[ Canopy instance registerDomainNamed: #alpha with: alpha.
	Canopy instance registerDomainNamed: #beta with: beta.
	response := CanopyMetricsHandler new handleRequest: nil.
	body := response entity contents.
	self assert: (body includesSubstring: 'alpha_memorySize').
	self assert: (body includesSubstring: 'beta_memorySize')
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyMetricsHandlerTest >> testHandleRequestExportsAMixedTreeWithoutTrippingOverConfiguration [
	"Without configured domains the handler formats the whole Canopy tree - which is where
	configuration and metrics actually meet, since both live in it. A single config cell used to
	end the request in a doesNotUnderstand: the visitor had no visitCell:. The claim that
	configuration and metrics are one tree held for the structure, not for the export."
	| mapping config response body |
	mapping := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	config := CanopyBranchNode new.
	config at: #port put: (CanopyCell new value: 5432).
	[ Canopy instance registerDomainNamed: #testMetrics with: mapping.
	Canopy instance registerDomainNamed: #testConfig with: config.
	response := CanopyMetricsHandler new handleRequest: nil.
	body := response entity contents.
	self assert: response isSuccess.
	self assert: (body includesSubstring: 'testMetrics_memorySize 1024 ').
	self deny: (body includesSubstring: '5432')
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyMetricsHandlerTest >> testHandleRequestWithConfiguredPrefixPrependsPrefix [
	"A configured domain can carry an export prefix (Option B, Canopy roadmap) - the metric
	name is prefixed, mirroring the old pharo_ namespace for system domains."
	| mapping handler response |
	mapping := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	[ Canopy instance registerDomainNamed: #virtualMachine with: mapping.
	handler := CanopyMetricsHandler new.
	handler addDomain: #virtualMachine prefix: 'pharo'.
	response := handler handleRequest: nil.
	self assert: (response entity contents includesSubstring: 'pharo_virtualMachine_memorySize')
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyMetricsHandlerTest >> testHandleRequestWithConfigOnlyExportsConfiguredDomains [
	"Configuring domains selects them: only the added domain is exported, siblings are skipped
	(not every domain has to be exported - Norbert, 2026-07-27)."
	| alpha beta handler body |
	alpha := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	beta := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	[ Canopy instance registerDomainNamed: #alpha with: alpha.
	Canopy instance registerDomainNamed: #beta with: beta.
	handler := CanopyMetricsHandler new.
	handler addDomain: #alpha.
	body := (handler handleRequest: nil) entity contents.
	self assert: (body includesSubstring: 'alpha_memorySize').
	self deny: (body includesSubstring: 'beta')
	] ensure: [ Canopy reset ]
]
