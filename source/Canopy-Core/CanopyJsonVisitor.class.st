Class {
	#name : 'CanopyJsonVisitor',
	#superclass : 'CanopyVisitor',
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'formatting' }
CanopyJsonVisitor >> format: aNode [
	"The traversal this used to do itself is asRawValue now, so a tree is turned into plain
	values in exactly one place - the same one that hands a subtree to a leaf."
	^ STON toJsonString: aNode asRawValue
]
