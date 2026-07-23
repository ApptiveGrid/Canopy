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
