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
	CanopyMetricGroup - #virtualMachine/#image (Canopy class>>systemMetrics) are plain
	branches, not metric groups. fullKey walks the real parent chain, independent of the
	visitor - no longer relies on the now-removed CanopyPrometheusVisitor>>prefixes."
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
CanopyMetricsVisitorTest >> testFormatMetricMapNestedInMetricGroupProducesPerLabelPrometheusLines [
	"Regression test for the previously dead CanopyPrometheusVisitor>>visitMetricGroup:/
	visitMetricMap: - CanopyMetricGroup/CanopyMetricMap did not exist before (see Canopy
	roadmap, Metriken aus pharo-metrics uebernehmen). Metric name is now the full underscore-
	joined tree path (fullKey), not the bare key - see testConvertMetricNameUsesFullTreePath."
	| mapBranch metricMap root group output |
	mapBranch := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	metricMap := mapBranch / #responsesByStatus.
	root := CanopyBranchNode new.
	group := CanopyMetricGroup new.
	root at: #zinc put: group.
	group at: #responsesByStatus put: metricMap.
	output := CanopyPrometheusVisitor new format: root.
	self assert: (output includesSubstring: '# HELP zinc_responsesByStatus Responses by status').
	self assert: (output includesSubstring: '# TYPE zinc_responsesByStatus gauge').
	self assert: (output includesSubstring: 'zinc_responsesByStatus{status="200"} 5 ').
	self assert: (output includesSubstring: 'zinc_responsesByStatus{status="404"} 2 ')
]

{ #category : 'as yet unclassified' }
CanopyMetricsVisitorTest >> testMetricGroupMetricsReturnsChildNodes [
	| group a b |
	group := CanopyMetricGroup new.
	a := CanopyCell new value: 1.
	b := CanopyCell new value: 2.
	group at: #a put: a.
	group at: #b put: b.
	self assertCollection: group metrics asArray hasSameElements: (Array with: a with: b)
]

{ #category : 'as yet unclassified' }
CanopyMetricsVisitorTest >> testMetricGroupNameReflectsPositionInTree [
	| root group |
	root := CanopyBranchNode new.
	group := CanopyMetricGroup new.
	root at: #zinc put: group.
	self assert: group name equals: #zinc
]

{ #category : 'as yet unclassified' }
CanopyMetricsVisitorTest >> testMetricMapAttributesAndValuesDoIteratesValueDictionary [
	| mapBranch metricMap seen |
	mapBranch := CanopyMappingBuilder new object: CanopyMetricsTestObject new; map: CanopyBranchNode new; build.
	metricMap := mapBranch / #responsesByStatus.
	seen := Dictionary new.
	metricMap attributesAndValuesDo: [ :status :count | seen at: status put: count ].
	self assert: (seen at: 200) equals: 5.
	self assert: (seen at: 404) equals: 2
]
