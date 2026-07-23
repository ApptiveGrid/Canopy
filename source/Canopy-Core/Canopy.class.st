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
	SmalltalkImage canopyRegister.
	Process canopyRegister.
	File canopyRegister.
	ExternalSemaphoreTable canopyRegister
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
	^ VirtualMachine canopyRegister
]

{ #category : 'domains' }
Canopy class >> registerZincMetrics [
	"Explicit opt-in - subscribes CanopyZincCounter to live Zinc server traffic and registers
	the #zinc domain. Not wired to any automatic image-startup hook, same reasoning as
	registerSystemMetrics: not everyone wants this without being asked."
	^ CanopyZincCounter canopyRegister
]

{ #category : 'initialization' }
Canopy class >> reset [ 
	instance := nil 
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
