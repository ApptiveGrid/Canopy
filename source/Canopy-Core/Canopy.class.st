Class {
	#name : 'Canopy',
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
Canopy class >> / aString [ 
	^ self instance / aString 
]

{ #category : 'arithmetic' }
Canopy class >> /+ aString [ 
	^ self instance /+ aString 
]

{ #category : 'accessing' }
Canopy class >> instance [ 
	^ instance ifNil: [ 
		instance := self new  ]
]

{ #category : 'initialization' }
Canopy class >> reset [ 
	instance := nil 
]

{ #category : 'as yet unclassified' }
Canopy class >> systemMetrics [ 
	^ CanopyMappingBuilder new 
		at: #image addMapping: Smalltalk;  
		at: #image addMapping: Process;
		at: #image addMapping: File;
		at: #image addMapping: ExternalSemaphoreTable;
		at: #virtualMachine addMapping: Smalltalk vm;
		map 
	
]
