"
An object that marks two methods with <canopyBranch>, which until 2026-09-21 was
a way to end up with no composed tree at all: the builder ran the marked method
only when there was exactly one of them, and said nothing otherwise.

Two rather than one is not exotic. It is what a subclass gets the moment it adds
a branch of its own to the one it inherits.
"
Class {
	#name : 'CanopyTwoBranchExample',
	#superclass : 'Object',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'building' }
CanopyTwoBranchExample >> canopyBranch: aBuilder [
	<canopyBranch>
	aBuilder map at: #first put: (CanopyCell new value: 1)
]

{ #category : 'building' }
CanopyTwoBranchExample >> canopySecondBranch: aBuilder [
	<canopyBranch>
	aBuilder map at: #second put: (CanopyCell new value: 2)
]
