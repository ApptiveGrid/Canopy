Class {
	#name : 'CanopyTagTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyTagTest >> testApplyIgnoresTagsEntirely [
	"Documents current design: tags are purely descriptive/informational. apply: has no
	tag-based filtering - a differently-tagged value is applied exactly the same way as an
	untagged one. See Canopy spec.md, Prioritaet 1 (open question: should tags ever be
	operative?)."
	| component tree object |
	tree := Canopy new importTree: '{ "one" : 1 }' tags: #( irrelevantTag ).
	component := CanopyBranchNode new.
	object := CanopyTestObject new.
	component at: #one put: (CanopyAccessor new object: object; selector: #one; yourself).
	component apply: tree.
	self assert: object one equals: 1
]

{ #category : 'as yet unclassified' }
CanopyTagTest >> testImportTreeTagsAppliesTagsToAllNodes [
	| tree |
	tree := Canopy new importTree: '{ "a" : { "b" : 1 } }' tags: #( mine ).
	self assertCollection: tree tags hasSameElements: #( mine ).
	self assertCollection: (tree / #a) tags hasSameElements: #( mine ).
	self assertCollection: (tree / #a / #b) tags hasSameElements: #( mine )
]

{ #category : 'as yet unclassified' }
CanopyTagTest >> testTagsAccumulateAcrossThreeOverlappingImports [
	| tree |
	tree := Canopy new.
	tree importTree: '{ "one" : 1 }' tags: #( appA ).
	tree importTree: '{ "one" : 2, "two" : 3 }' tags: #( appB ).
	tree importTree: '{ "one" : 4 }' tags: #( appC ).
	self assertCollection: (tree / #one) tags hasSameElements: #( appA appB appC ).
	self assertCollection: (tree / #two) tags hasSameElements: #( appB ).
	self assert: (tree / #one) value equals: 4
]
