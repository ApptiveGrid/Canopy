Class {
	#name : 'CanopyJsonVisitor',
	#superclass : 'CanopyVisitor',
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'formatting' }
CanopyJsonVisitor >> format: aNode [
	^ NeoJSONWriter toString: (self visit: aNode)
]

{ #category : 'visiting' }
CanopyJsonVisitor >> visit: anObject [
	^ anObject acceptCanopy: self
]

{ #category : 'visiting' }
CanopyJsonVisitor >> visitBranchNode: aCanopyBranchNode [
	| result |
	result := Dictionary new.
	aCanopyBranchNode nodes keysAndValuesDo: [ :key :childNode |
		result at: key put: (self visit: childNode) ].
	^ result
]

{ #category : 'visiting' }
CanopyJsonVisitor >> visitCell: aCanopyCell [
	^ aCanopyCell value
]

{ #category : 'visiting' }
CanopyJsonVisitor >> visitDictionaryAccessor: aCanopyDictionaryAccessor [
	^ aCanopyDictionaryAccessor value
]

{ #category : 'visiting' }
CanopyJsonVisitor >> visitMetric: aCanopyAccessor [
	^ aCanopyAccessor value
]
