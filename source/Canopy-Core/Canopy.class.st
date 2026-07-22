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
Canopy class >> domainNames [
	^ self instance domainNames
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
Canopy class >> registerDomainNamed: aSymbol with: aNode [
	^ self instance registerDomainNamed: aSymbol with: aNode
]

{ #category : 'domains' }
Canopy class >> registerImageMetrics [
	"Explicit opt-in, independently selectable from registerVirtualMachineMetrics."
	^ self registerDomainNamed: #image with: (self systemMetrics / #image)
]

{ #category : 'domains' }
Canopy class >> registerSystemMetrics [
	"Convenience wrapper - registers both system-metrics domains. Not wired to any
	automatic image-startup hook - a caller decides when (or whether) to invoke this."
	self registerImageMetrics.
	self registerVirtualMachineMetrics
]

{ #category : 'domains' }
Canopy class >> registerVirtualMachineMetrics [
	"Explicit opt-in, independently selectable from registerImageMetrics."
	^ self registerDomainNamed: #virtualMachine with: (self systemMetrics / #virtualMachine)
]

{ #category : 'domains' }
Canopy class >> registerZincMetrics [
	"Explicit opt-in - subscribes CanopyZincCounter to live Zinc server traffic and registers
	the #zinc domain. Not wired to any automatic image-startup hook, same reasoning as
	registerSystemMetrics: not everyone wants this without being asked."
	CanopyZincCounter install.
	^ self registerDomainNamed: #zinc with: (self zincMetrics / #zinc)
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

{ #category : 'metrics' }
Canopy class >> zincMetrics [
	^ CanopyMappingBuilder new
		at: #zinc addMapping: CanopyZincCounter instance;
		map
]

{ #category : 'domains' }
Canopy >> domainNames [
	^ self keys
]

{ #category : 'domains' }
Canopy >> domains [
	^ self nodes values
]

{ #category : 'domains' }
Canopy >> registerDomainNamed: aSymbol with: aNode [
	(nodes includesKey: aSymbol) ifTrue: [ 
		^ self error: 'domain ' , aSymbol asString , ' is already registered' ].
	^ self at: aSymbol put: aNode
]
