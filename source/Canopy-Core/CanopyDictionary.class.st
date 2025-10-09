Class {
	#name : 'CanopyDictionary',
	#superclass : 'CanopyLeafNode',
	#instVars : [
		'dictionary'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'instance creation' }
CanopyDictionary class >> on: aDictionary [ 
	^ self new 
		dictionary: aDictionary 
]

{ #category : 'accessing' }
CanopyDictionary class >> type [ 
	^ #dictionary 
]

{ #category : 'target resize' }
CanopyDictionary >> apply: aCanopyBranchNode [ 

	aCanopyBranchNode keysAndValuesDo: [ :key :value |
		dictionary at: key put: value value ]
]

{ #category : 'accessing' }
CanopyDictionary >> dictionary: aCollection [ 
	dictionary := aCollection
]
