Class {
	#name : 'CanopyJsonTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyJsonTest >> sampleJsonConfiguration [
	^ '{
		"one" : "onestring"
		}'
]

{ #category : 'tests' }
CanopyJsonTest >> testReadJson [ 
	| tree |
	tree := CanopyTree new importTree: self sampleJsonConfiguration.
	self assert: (tree / #one) value equals: 'onestring'.

]

{ #category : 'tests' }
CanopyJsonTest >> testReadJsonTwice [
	| tree |
	tree := CanopyTree new importTree: self sampleJsonConfiguration.
	self assert: (tree / #one) value equals: 'onestring'.
	tree importTree: '{
		"one" : "one new string",
		"two" : "twostring"
		}'.
	"for now we merge in overwriting mode"
	self assert: (tree / #one) value equals: 'one new string'.
	self assert: (tree / #two) value equals: 'twostring'.



]

{ #category : 'tests' }
CanopyJsonTest >> testReadJsonTwiceWithTags [
	| tree |
	tree := CanopyTree new 
		importTree: self sampleJsonConfiguration
		tags: #( first ) .
	self assert: (tree / #one) value equals: 'onestring'.
	tree 
		importTree: '{
			"one" : "one new string",
			"two" : "twostring"
			}'
		tags: #( second ).
	"for now we merge in overwriting mode"
	self assert: (tree / #one) value equals: 'one new string'.
	self assert: (tree / #two) value equals: 'twostring'.
	
	self assertCollection: tree tags hasSameElements: #( first second ).
	self assertCollection: (tree / #one) tags hasSameElements: #( first second ).
	self assertCollection: (tree / #two) tags hasSameElements: #(  second ).




]
