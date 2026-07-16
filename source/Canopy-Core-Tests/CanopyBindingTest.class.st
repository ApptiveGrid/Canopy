Class {
	#name : 'CanopyBindingTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testBindAfterValueIsSet [
	| tree object |
	tree := Canopy new importTree: '{ "one" : 42 }'.
	object := CanopyTestObject new.
	object canopyBind: tree keys: #( one ).
	self assert: object one equals: 42
]

{ #category : 'tests' }
CanopyBindingTest >> testBindProperties [
	| tree object |
	tree := Canopy new importTree: '{ "first" : { "second" : { "one" : 1, "two": 2, "three" : 3 }}}'.
	object := CanopyTestObject new
		canopyBind: tree / #first / #second keys: #( one two three ).
	self assert: object one equals: 1.
	self assert: object two equals: 2.
	self assert: object three equals: 3
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testHotReloadNotPropagatedToBoundObject [
	"Fixed 2026-07-17: CanopyCell>>value: now notifies a registered dependent accessor."
	| tree object |
	tree := Canopy new.
	tree at: #one put: CanopyCell new.
	object := CanopyTestObject new.
	object canopyBind: tree keys: #( one ).
	(tree / #one) value: 42.
	self assert: object one equals: 42
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testHotReloadViaReimport [
	"Fixed 2026-07-17: CanopyCell>>register: now always tracks dependents, regardless of
	whether a value already existed at bind time."
	| tree object |
	tree := Canopy new importTree: '{ "one" : 1 }'.
	object := CanopyTestObject new.
	object canopyBind: tree keys: #( one ).
	self assert: object one equals: 1.
	tree importTree: '{ "one" : 2 }'.
	self assert: object one equals: 2
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testMultipleAccessorRegistrationsAreAllNotified [
	"Fixed 2026-07-17: CanopyCell>>register: now keeps a dependents collection instead of a
	single slot - both accessors registered before a value exists are notified once it is set."
	| value accessorA accessorB objectA objectB |
	value := CanopyCell new.
	objectA := CanopyTestObject new.
	objectB := CanopyTestObject new.
	accessorA := CanopyAccessor new object: objectA; selector: #one; yourself.
	accessorB := CanopyAccessor new object: objectB; selector: #one; yourself.
	value register: accessorA.
	value register: accessorB.
	value value: 99.
	self assert: objectA one equals: 99.
	self assert: objectB one equals: 99
]
