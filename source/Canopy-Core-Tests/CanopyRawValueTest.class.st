Class {
	#name : 'CanopyRawValueTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'tests' }
CanopyRawValueTest >> testABranchBecomesANestedDictionary [
	| root |
	root := CanopyBranchNode new.
	root at: #config put: (CanopyCell new value: 'hello').
	self assert: (STON toJsonString: root asRawValue) equals: '{"config":"hello"}'
]

{ #category : 'tests' }
CanopyRawValueTest >> testACellBecomesItsBareValue [
	self assert: (STON toJsonString: (CanopyCell new value: 'hello') asRawValue) equals: '"hello"'
]

{ #category : 'tests' }
CanopyRawValueTest >> testASubtreeSinkAnswersItsLiveDictionary [
	| built root |
	built := CanopyMappingBuilder new object: (CanopyDictionaryTestObject new settings: (Dictionary new at: #a put: 1; yourself); yourself); map: CanopyBranchNode new; build.
	root := CanopyBranchNode new.
	root at: #settings put: (built at: #settings).
	self assert: (STON toJsonString: root asRawValue) equals: '{"settings":{"a":1}}'
]

{ #category : 'tests' }
CanopyRawValueTest >> testAReadableLeafAnswersWhatItReads [
	| built root |
	built := CanopyMappingBuilder new object: (CanopyTestObject new one: 42; yourself); map: CanopyBranchNode new; build.
	root := CanopyBranchNode new.
	root at: #one put: (built at: #one).
	self assert: (STON toJsonString: root asRawValue) equals: '{"one":42}'
]

{ #category : 'tests' }
CanopyRawValueTest >> testAWriteOnlyLeafAnswersNilInsteadOfCrashing [
	"Mirrors CanopyAccessorTest>>testAcceptCanopySkipsWriteOnlyAccessorsInsteadOfCrashing -
	but unlike the Prometheus visitor (which omits the key entirely), JSON keeps the key
	with an explicit null so a browse client still sees the leaf exists, just unreadable."
	| root writeOnly |
	root := CanopyBranchNode new.
	writeOnly := CanopyAccessor new object: CanopyTestObject new; writeSelector: #one; yourself.
	root at: #writeOnlyThing put: writeOnly.
	self assert: (STON toJsonString: root asRawValue) equals: '{"writeOnlyThing":null}'
]
