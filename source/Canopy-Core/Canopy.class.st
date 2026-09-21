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

{ #category : 'accessing' }
Canopy class >> instance: aCanopy [
	"Put a tree back that #useNewInstanceDuring: took away. Nothing else has business
	replacing the singleton - #reset is how you let go of one."
	instance := aCanopy
]

{ #category : 'domains' }
Canopy class >> registerDomainNamed: aSymbol with: aNode [
	^ self instance registerDomainNamed: aSymbol with: aNode
]

{ #category : 'domains' }
Canopy class >> registerImageMetrics [
	"Lands under the #pharo domain, see registerSystemMetrics."
	SmalltalkImage canopyRegister.
	Process canopyRegister.
	File canopyRegister
]

{ #category : 'domains' }
Canopy class >> registerSystemMetrics [
	"Everything Pharo says about itself, under the domain #pharo. That is where the exported
	names pharo_image_... and pharo_virtualMachine_... come from: a metric is named after where
	it hangs, so the tree says it once instead of the endpoint renaming it a second time.
	Not wired to any automatic image-startup hook - a caller decides when (or whether) to
	invoke this."
	self registerImageMetrics.
	self registerVirtualMachineMetrics
]

{ #category : 'domains' }
Canopy class >> registerVirtualMachineMetrics [
	"Lands under the #pharo domain, see registerSystemMetrics."
	VirtualMachine canopyRegister.
	^ ExternalSemaphoreTable canopyRegister
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

{ #category : 'initialization' }
Canopy class >> useNewInstanceDuring: aBlock [
	"Evaluate aBlock against a fresh, empty tree and put the previous one back afterwards.

	For a test that has to register domains of its own. #reset alone was what such a test
	used to do, and it is right in an image that exists for the test run - but these test
	classes travel into the server images, and AGTestRunnerHandler runs any TestCase suite
	in the image it is asked for over /health. There #reset takes the tree the server is
	serving: #instance lazily builds an empty one, setupMetrics never runs again, and
	/metrics answers 200 with an empty body. A scrape cannot tell that from silence."
	| previous |
	previous := instance.
	instance := self new.
	^ aBlock ensure: [ instance := previous ]
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
