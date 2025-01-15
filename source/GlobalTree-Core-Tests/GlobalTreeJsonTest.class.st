Class {
	#name : 'GlobalTreeJsonTest',
	#superclass : 'TestCase',
	#category : 'GlobalTree-Core-Tests',
	#package : 'GlobalTree-Core-Tests'
}

{ #category : 'as yet unclassified' }
GlobalTreeJsonTest >> sampleJsonConfiguration [
	^ '{
		"one" : "onestring"
		}'
]

{ #category : 'tests' }
GlobalTreeJsonTest >> testReadJson [ 
	| tree |
	tree := GlobalTree new importTree: self sampleJsonConfiguration.
	self assert: (tree / #one) value equals: 'onestring'.

]

{ #category : 'tests' }
GlobalTreeJsonTest >> testReadJsonTwice [
	| tree |
	tree := GlobalTree new importTree: self sampleJsonConfiguration.
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
GlobalTreeJsonTest >> testReadJsonTwiceWithTags [
	| tree |
	tree := GlobalTree new 
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
