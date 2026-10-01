Class {
	#name : 'CanopyDescriptionTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'tests' }
CanopyDescriptionTest >> testABranchAndACellCarryADescription [
	| branch cell |
	branch := CanopyBranchNode new.
	cell := CanopyCell new value: 1.
	branch description: 'where the limits live'.
	cell description: 'the maximum of open files'.
	self assert: branch description equals: 'where the limits live'.
	self assert: cell description equals: 'the maximum of open files'
]

{ #category : 'tests' }
CanopyDescriptionTest >> testAHolderCarriesADescriptionAndLabels [
	| holder |
	holder := CanopyValue value: 1.
	holder description: 'what the component says'.
	holder labelAt: #database put: 'alpha'.
	self assert: holder description equals: 'what the component says'.
	self assert: (holder labels at: #database) equals: 'alpha'
]

{ #category : 'tests' }
CanopyDescriptionTest >> testNothingIsDescribedUnlessSomeoneSaidSo [
	self assert: CanopyBranchNode new description isNil.
	self assert: (CanopyCell new value: 1) description isNil.
	self assert: (CanopyValue value: 1) description isNil.
	self assert: (CanopyValue value: 1) labels isEmpty
]
