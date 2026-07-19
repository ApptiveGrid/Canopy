Class {
	#name : 'CanopyDictionaryAccessor',
	#superclass : 'CanopyLeafNode',
	#instVars : [
		'dictionary'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'instance creation' }
CanopyDictionaryAccessor class >> on: aDictionary [ 
	^ self new 
		dictionary: aDictionary 
]

{ #category : 'accessing' }
CanopyDictionaryAccessor class >> type [ 
	^ #dictionary 
]

{ #category : 'target resize' }
CanopyDictionaryAccessor >> apply: aCanopyBranchNode [ 

	aCanopyBranchNode keysAndValuesDo: [ :key :value |
		dictionary at: key put: value value ]
]

{ #category : 'target resize' }
CanopyDictionaryAccessor >> apply: aCanopyBranchNode withTag: aTag [
	(aCanopyBranchNode tags includes: aTag) ifTrue: [
		self apply: aCanopyBranchNode ]
]

{ #category : 'accessing' }
CanopyDictionaryAccessor >> dictionary: aCollection [
	dictionary := aCollection
]
