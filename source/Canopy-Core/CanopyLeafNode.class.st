Class {
	#name : 'CanopyLeafNode',
	#superclass : 'CanopyNode',
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'accessing' }
CanopyLeafNode class >> withType: aString [ 
	self subclassesDo: [ :cls |
		(cls type = aString) ifTrue: [ 
			^ cls ] ].
	self error: 'could not find leaf node type ', aString asString
]

{ #category : 'arithmetic' }
CanopyLeafNode >> / aString [ 
	Error signal: 'a value can not be traversed'
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
