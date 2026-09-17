Class {
	#name : 'CanopyLeafNode',
	#superclass : 'CanopyNode',
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'arithmetic' }
CanopyLeafNode >> / aString [ 
	Error signal: 'a value can not be traversed'
]

{ #category : 'target resize' }
CanopyLeafNode >> apply: aCanopyBranchNode [
	"A leaf handed a whole subtree takes it as a single value: the component's own write method
	receives a plain nested Dictionary and decides itself whether to replace or to merge."
	self value: aCanopyBranchNode asRawValue
]

{ #category : 'target resize' }
CanopyLeafNode >> apply: aCanopyBranchNode withTag: aTag [
	(aCanopyBranchNode tags includes: aTag) ifTrue: [
		self apply: aCanopyBranchNode ]
]

{ #category : 'converting' }
CanopyLeafNode >> asRawValue [
	^ self value
]

{ #category : 'accessing' }
CanopyLeafNode >> inspectionKey [ 
	^ self key 
]

{ #category : 'accessing' }
CanopyLeafNode >> inspectionValue [
	^ self value 
]

{ #category : 'actions' }
CanopyLeafNode >> mergeInto: aGlobValueHolder [
	"Default conflict for leaf types with no defined merge semantics (Accessor,
	DictionaryAccessor, Metric - they bind to a live object, merging them makes no sense).
	CanopyCell overrides this itself since it DOES have real merge semantics."
	self error: 'conflict'
]

{ #category : 'enumerating' }
CanopyLeafNode >> recursiveDo: aBlock [ 
	aBlock value: self 
]
