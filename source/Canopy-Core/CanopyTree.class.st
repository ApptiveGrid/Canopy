Class {
	#name : 'CanopyTree',
	#superclass : 'CanopyBranchNode',
	#instVars : [
		'root'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'arithmetic' }
CanopyTree class >> / aString [ 
	^ self instance / aString 
]

{ #category : 'arithmetic' }
CanopyTree class >> /+ aString [ 
	^ self instance /+ aString 
]

{ #category : 'accessing' }
CanopyTree class >> instance [ 
	^ instance ifNil: [ 
		instance := self new  ]
]

{ #category : 'initialization' }
CanopyTree class >> reset [ 
	instance := nil 
]
