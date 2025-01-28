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

{ #category : 'enumerating' }
CanopyLeafNode >> recursiveDo: aBlock [ 
	aBlock value: self 
]
