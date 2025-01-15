Class {
	#name : 'GlobalTree',
	#superclass : 'GlobBranch',
	#instVars : [
		'root'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'arithmetic' }
GlobalTree class >> / aString [ 
	^ self instance / aString 
]

{ #category : 'arithmetic' }
GlobalTree class >> /+ aString [ 
	^ self instance /+ aString 
]

{ #category : 'accessing' }
GlobalTree class >> instance [ 
	^ instance ifNil: [ 
		instance := self new  ]
]

{ #category : 'initialization' }
GlobalTree class >> reset [ 
	instance := nil 
]
