Class {
	#name : 'GlobalTreeBindingTest',
	#superclass : 'TestCase',
	#category : 'GlobalTree-Core-Tests',
	#package : 'GlobalTree-Core-Tests'
}

{ #category : 'tests' }
GlobalTreeBindingTest >> testBindProperties [ 
	| tree object |
	self halt.
	tree := GlobalTree new importTree: '{ "first" : { "second" : { "one" : 1, "two": 2, "three" : 3 }}}'.
	object := GlobalTreeTestObject new 
		globalTreeBind: tree / #first / #second keys: #( one two three ).
	self halt.
]
