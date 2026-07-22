Class {
	#name : 'CanopyAccessorTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testAcceptCanopySkipsWriteOnlyAccessorsInsteadOfCrashing [
	"Found 2026-07-21 while sanity-checking format: over the real Canopy systemMetrics
	tree: VirtualMachine>>maximumExternalSemaphoresCanopy: is a #accessor (write-only)
	pragma sitting in the same tree as real #metric values under #virtualMachine. Before
	this fix, acceptCanopy: unconditionally dispatched to visitMetric:, which crashed on
	nil name/description for any write-only accessor. Write-only accessors must not break
	formatting of a tree they happen to be mixed into."
	| root writeOnly output |
	root := CanopyBranchNode new.
	writeOnly := CanopyAccessor new object: CanopyTestObject new; writeSelector: #one; yourself.
	root at: #writeOnlyThing put: writeOnly.
	output := CanopyPrometheusVisitor new format: root.
	self assert: output isEmpty
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testDictionaryAccessorBuiltFromPragmaWrapsLiveDictionary [
	"Fixed 2026-07-21: CanopyDictionaryAccessor had neither object: nor
	initializeFromPragma: - <canopyValue: ... type: #dictionary ...> would crash with
	doesNotUnderstand: #object: inside CanopyMappingBuilder. Verified nobody used this
	pragma type before the fix (dead but real gap)."
	| built leaf dict |
	dict := Dictionary new at: #a put: 1; yourself.
	built := CanopyMappingBuilder new object: (CanopyDictionaryTestObject new settings: dict; yourself); map: CanopyBranchNode new; build.
	leaf := built / #settings.
	self assert: leaf class equals: CanopyDictionaryAccessor.
	self assert: leaf value equals: dict.
	leaf apply: (CanopyBranchNode new at: #b put: (CanopyCell new value: 2); yourself).
	self assert: (dict at: #b) equals: 2
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testMetricPragmaStillPopulatesReadSelectorAndMetadata [
	"Regression: the #metric pragma path (used by dozens of existing VM/Image/Zinc
	methods, but kept package-local here to avoid a Core-Tests -> Metrics-Tests
	dependency) must still populate readSelector/name/description/valueType exactly as
	before, now that CanopyMetric itself is gone - CanopyAccessor absorbs its role."
	| object built leaf |
	object := CanopyTestObject new.
	object one: 42.
	built := CanopyMappingBuilder new object: object; map: CanopyBranchNode new; build.
	leaf := built / #one.
	self assert: leaf class equals: CanopyAccessor.
	self assert: leaf value equals: 42.
	self assert: leaf description equals: 'The configured one value'.
	self assert: leaf valueType equals: #gauge.
	self should: [ leaf value: 1 ] raise: Error "still read-only, no writeSelector"
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testReadAndWriteSelectorsWorkIndependentlyOnTheSameInstance [
	"The whole point of the unification: one leaf type, read and write are just optional
	selectors, not separate classes. Read and write here intentionally target different
	object properties to prove they are independent, not coupled."
	| object accessor |
	object := CanopyTestObject new.
	object one: 1; two: 2.
	accessor := CanopyAccessor new
		object: object;
		readSelector: #one;
		writeSelector: #two;
		yourself.
	self assert: accessor value equals: 1.
	accessor value: 99.
	self assert: object two equals: 99.
	self assert: object one equals: 1 "read selector target is untouched by the write"
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testValueRaisesControlledErrorWhenNoReadSelector [
	"Fixed 2026-07-21 (Accessor/Metric-Vereinheitlichung): previously value was simply
	undefined for a write-only accessor - would raise a raw doesNotUnderstand if ever
	visited/read. Now a controlled error, matching the merge-conflict philosophy elsewhere."
	self should: [ CanopyAccessor new value ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testValueWriteRaisesControlledErrorWhenNoWriteSelector [
	"Mirrors the old CanopyMetric>>value: ('a metric cannot be written') - a read-only
	accessor now raises the same kind of controlled error for the opposite direction."
	self should: [ CanopyAccessor new value: 5 ] raise: Error
]
