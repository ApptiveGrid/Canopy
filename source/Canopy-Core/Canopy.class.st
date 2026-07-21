Class {
	#name : 'Canopy',
	#superclass : 'CanopyBranchNode',
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

{ #category : 'domains' }
Canopy class >> attachSystemMetrics [
	"Convenience wrapper - registers both system-metrics domains. Not wired to any
	automatic image-startup hook - a caller decides when (or whether) to invoke this."
	self registerImageMetrics.
	self registerVirtualMachineMetrics
]

{ #category : 'domains' }
Canopy class >> domains [
	^ self instance domains
]

{ #category : 'accessing' }
Canopy class >> instance [ 
	^ instance ifNil: [ 
		instance := self new  ]
]

{ #category : 'domains' }
Canopy class >> registerDomain: aSymbol with: aNode [
	^ self instance registerDomain: aSymbol with: aNode
]

{ #category : 'domains' }
Canopy class >> registerImageMetrics [
	"Explicit opt-in, independently selectable from registerVirtualMachineMetrics."
	^ self registerDomain: #image with: (self systemMetrics / #image)
]

{ #category : 'domains' }
Canopy class >> registerVirtualMachineMetrics [
	"Explicit opt-in, independently selectable from registerImageMetrics."
	^ self registerDomain: #virtualMachine with: (self systemMetrics / #virtualMachine)
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

{ #category : 'domains' }
Canopy >> domains [
	^ self keys
]

{ #category : 'domains' }
Canopy >> registerDomain: aSymbol with: aNode [
	(nodes includesKey: aSymbol) ifTrue: [ 
		^ self error: 'domain ' , aSymbol asString , ' is already registered' ].
	^ self at: aSymbol put: aNode
]
