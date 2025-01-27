Class {
	#name : 'CanopyBindingTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'tests' }
CanopyBindingTest >> testBindProperties [ 
	| tree object |
	tree := CanopyTree new importTree: '{ "first" : { "second" : { "one" : 1, "two": 2, "three" : 3 }}}'.
	object := CanopyTestObject new 
		canopyBind: tree / #first / #second keys: #( one two three ).

]
