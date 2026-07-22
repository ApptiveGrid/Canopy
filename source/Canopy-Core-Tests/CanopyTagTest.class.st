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
	component at: #one put: (CanopyAccessor new object: object; writeSelector: #one; yourself).
	component apply: tree.
	self assert: object one equals: 1
]

{ #category : 'as yet unclassified' }
CanopyTagTest >> testApplyWithTagOnlyAppliesMatchingTaggedValues [
	"apply:withTag: filters at the leaf level - only values tagged with the given tag
	are pushed into the component tree. Differently-tagged values interleaved in the
	same branch are left untouched, unlike plain apply: (see testApplyIgnoresTagsEntirely)."
	| component tree object |
	tree := Canopy new.
	tree importTree: '{ "one" : 1 }' tags: #( config ).
	tree importTree: '{ "two" : 2 }' tags: #( metrics ).
	component := CanopyBranchNode new.
	object := CanopyTestObject new.
	object one: 0; two: 0.
	component at: #one put: (CanopyAccessor new object: object; writeSelector: #one; yourself).
	component at: #two put: (CanopyAccessor new object: object; writeSelector: #two; yourself).
	component apply: tree withTag: #config.
	self assert: object one equals: 1.
	self assert: object two equals: 0
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
