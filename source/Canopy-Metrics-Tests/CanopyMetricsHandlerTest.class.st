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
