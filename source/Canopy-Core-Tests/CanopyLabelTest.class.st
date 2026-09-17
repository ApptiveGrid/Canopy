Class {
	#name : 'CanopyLabelTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyLabelTest >> testALabelOnTheNodeBeatsAnInheritedOne [
	"Merging is parent labels , own labels, so the entry closer to the value wins."
	| root leaf |
	root := CanopyBranchNode new.
	leaf := CanopyCell new value: 1.
	root at: #child put: leaf.
	root labelAt: #stage put: 'production'.
	leaf labelAt: #stage put: 'test'.
	self assert: (leaf labels at: #stage) equals: 'test'.
	self assert: (root labels at: #stage) equals: 'production'
]

{ #category : 'as yet unclassified' }
CanopyLabelTest >> testLabelsWalkUpTheParentChain [
	"One label at the root reaches every node below it - the same walk allKeys does for the
	name. Without it the global stage label of the deployed servers cannot be rebuilt."
	| root branch leaf |
	root := CanopyBranchNode new.
	branch := CanopyBranchNode new.
	leaf := CanopyCell new value: 1.
	root at: #virtualMachine put: branch.
	branch at: #memorySize put: leaf.
	root labelAt: #stage put: 'production'.
	branch labelAt: #source put: 'vm'.
	self assert: (leaf labels at: #stage) equals: 'production'.
	self assert: (leaf labels at: #source) equals: 'vm'.
	self assert: leaf labels size equals: 2.
	self assert: root labels size equals: 1
]
