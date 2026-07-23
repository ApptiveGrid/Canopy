Class {
	#name : 'CanopyJsonVisitorTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'tests' }
CanopyJsonVisitorTest >> testFormatBranchNodeProducesNestedJsonObject [
	| root |
	root := CanopyBranchNode new.
	root at: #config put: (CanopyCell new value: 'hello').
	self assert: (CanopyJsonVisitor new format: root) equals: '{"config":"hello"}'
]

{ #category : 'tests' }
CanopyJsonVisitorTest >> testFormatCellReturnsRawJsonValue [
	self assert: (CanopyJsonVisitor new format: (CanopyCell new value: 'hello')) equals: '"hello"'
]

{ #category : 'tests' }
CanopyJsonVisitorTest >> testFormatDictionaryAccessorProducesNestedJsonObjectFromLiveDictionary [
	| built root |
	built := CanopyMappingBuilder new object: (CanopyDictionaryTestObject new settings: (Dictionary new at: #a put: 1; yourself); yourself); map: CanopyBranchNode new; build.
	root := CanopyBranchNode new.
	root at: #settings put: (built at: #settings).
	self assert: (CanopyJsonVisitor new format: root) equals: '{"settings":{"a":1}}'
]

{ #category : 'tests' }
CanopyJsonVisitorTest >> testFormatMetricAccessorUsesReadSelectorValue [
	| built root |
	built := CanopyMappingBuilder new object: (CanopyTestObject new one: 42; yourself); map: CanopyBranchNode new; build.
	root := CanopyBranchNode new.
	root at: #one put: (built at: #one).
	self assert: (CanopyJsonVisitor new format: root) equals: '{"one":42}'
]

{ #category : 'tests' }
CanopyJsonVisitorTest >> testFormatWriteOnlyAccessorProducesJsonNullInsteadOfCrashing [
	"Mirrors CanopyAccessorTest>>testAcceptCanopySkipsWriteOnlyAccessorsInsteadOfCrashing -
	but unlike the Prometheus visitor (which omits the key entirely), JSON keeps the key
	with an explicit null so a browse client still sees the leaf exists, just unreadable."
	| root writeOnly |
	root := CanopyBranchNode new.
	writeOnly := CanopyAccessor new object: CanopyTestObject new; writeSelector: #one; yourself.
	root at: #writeOnlyThing put: writeOnly.
	self assert: (CanopyJsonVisitor new format: root) equals: '{"writeOnlyThing":null}'
]
