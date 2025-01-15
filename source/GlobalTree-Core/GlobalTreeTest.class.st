Class {
	#name : 'GlobalTreeTest',
	#superclass : 'TestCase',
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'as yet unclassified' }
GlobalTreeTest >> sampleJsonConfiguration [
	^ '{
		"one" : "onestring"
		}'
]

{ #category : 'tests' }
GlobalTreeTest >> testReadJson [ 
	| tree |
	tree := GlobalTree new importTree: self sampleJsonConfiguration.
	self assert: (tree / #one) value equals: 'onestring'.

]

{ #category : 'tests' }
GlobalTreeTest >> testReadJsonTwice [
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
