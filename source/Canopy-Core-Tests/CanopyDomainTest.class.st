Class {
	#name : 'CanopyDomainTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testAtAddMergesInsteadOfOverwriting [
	| root incoming |
	root := Canopy new.
	root at: #image put: (CanopyBranchNode new at: #a put: (CanopyCell new value: 1); yourself).
	incoming := CanopyBranchNode new at: #b put: (CanopyCell new value: 2); yourself.
	root at: #image add: incoming.
	self assert: (root / #image / #a) value equals: 1.
	self assert: (root / #image / #b) value equals: 2
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testAtMissingKeyRaisesNotFound [
	| root |
	root := Canopy new.
	self should: [ root / #missing ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testAtOperatorCombinesPathAndValue [
	| root |
	root := Canopy new.
	root at: #leaf put: (CanopyCell new value: 42).
	self assert: (root @ #leaf) equals: 42
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testAtPutOnExistingDomainKeyOverwritesWithoutWarning [
	"at:put: itself intentionally stays ungated — it is also used internally for tree/merge
	mechanics that rely on overwrite semantics. Callers that want collision protection for
	top-level domains should use registerDomainNamed:with: instead (see testRegisterDomainNamedRaisesOnCollisionAndDoesNotOverwrite).
	This test documents that at:put: itself still silently overwrites."
	| root replacement |
	root := Canopy new.
	root at: #image put: (CanopyCell new value: 'original').
	replacement := CanopyCell new value: 'replaced'.
	root at: #image put: replacement.
	self assert: (root / #image) value equals: 'replaced'
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testDomainNamesListsAllRegisteredDomainNames [
	| root |
	root := Canopy new.
	root registerDomainNamed: #image with: (CanopyCell new value: 1).
	root registerDomainNamed: #virtualMachine with: (CanopyCell new value: 2).
	self assertCollection: root domainNames asArray hasSameElements: #( #image #virtualMachine )
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testDomainsReturnsRegisteredNodes [
	"domains returns the registered domain nodes themselves (Norbert, 2026-07-21: a domain is
	what got registered under a name, not the name itself - domainNames is for the names)."
	| root imageNode vmNode |
	root := Canopy new.
	imageNode := CanopyCell new value: 1.
	vmNode := CanopyCell new value: 2.
	root registerDomainNamed: #image with: imageNode.
	root registerDomainNamed: #virtualMachine with: vmNode.
	self assertCollection: root domains asArray hasSameElements: (Array with: imageNode with: vmNode)
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testEnsureAtCreatesMissingBranch [
	| root |
	root := Canopy new.
	self assert: (root /+ #newDomain) class equals: CanopyBranchNode.
	self assert: (root / #newDomain) class equals: CanopyBranchNode
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testFullKeyJoinsAncestorKeysWithUnderscore [
	| root leaf |
	root := Canopy new.
	leaf := CanopyCell new value: 42.
	(root /+ #virtualMachine) at: #memorySize put: leaf.
	self assert: leaf fullKey equals: 'virtualMachine_memorySize'.
	self assert: (root / #virtualMachine) fullKey equals: 'virtualMachine'
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testFullKeyOnRootIsEmpty [
	self assert: Canopy new fullKey equals: ''
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testMultipleDomainsCoexistIndependently [
	| root |
	root := Canopy new.
	root at: #image put: (CanopyCell new value: 'image-value').
	root at: #virtualMachine put: (CanopyCell new value: 'vm-value').
	self assert: (root / #image) value equals: 'image-value'.
	self assert: (root / #virtualMachine) value equals: 'vm-value'.
	self assertCollection: root keys asArray hasSameElements: #( image virtualMachine )
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testRegisterDomainNamedAddsNewDomain [
	| root |
	root := Canopy new.
	root registerDomainNamed: #image with: (CanopyCell new value: 1).
	self assert: (root / #image) value equals: 1.
	self assert: root domainNames asArray equals: #( #image )
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testRegisterDomainNamedRaisesOnCollisionAndDoesNotOverwrite [
	| root |
	root := Canopy new.
	root registerDomainNamed: #image with: (CanopyCell new value: 1).
	self should: [ root registerDomainNamed: #image with: (CanopyCell new value: 2) ] raise: Error.
	self assert: (root / #image) value equals: 1
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testRegisterImageMetricsRegistersTheImageHalfUnderPharo [
	"What Pharo says about itself is one domain, #pharo, with the image half below it - the
	exported name pharo_image_... is that path and nothing else."
	[ Canopy registerImageMetrics.
	self assert: Canopy domainNames asArray equals: #( #pharo ).
	self assert: (Canopy / #pharo) keys asArray equals: #( #image ) ]
		ensure: [ Canopy reset ]
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testRegisterSystemMetricsRegistersImageAndVirtualMachineDomains [
	"registerSystemMetrics is an explicit opt-in, not an automatic image-startup hook (Norbert,
	2026-07-21: not everyone wants this without being asked) - a caller invokes it themselves.
	Both halves land under the single domain #pharo, which is where the deployed names come
	from - see Canopy class>>registerSystemMetrics."
	[ Canopy registerSystemMetrics.
	self assert: Canopy domainNames asArray equals: #( #pharo ).
	self assertCollection: (Canopy / #pharo) keys asArray hasSameElements: #( #image #virtualMachine ) ]
		ensure: [ Canopy reset ]
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testRegisterSystemMetricsTwiceLeavesTheSameTree [
	"An image can reach its setup a second time - a REPL that stops the server and starts it
	again, a test that exercises the deployment path. This used to raise 'conflict': every
	class merges its declarations into the same node, and a leaf bound to a live object
	refused to merge with a second one, even when the second one said exactly the same."
	[ Canopy registerSystemMetrics.
	Canopy registerSystemMetrics.
	self assert: Canopy domainNames asArray equals: #( #pharo ).
	self assertCollection: (Canopy / #pharo) keys asArray hasSameElements: #( #image #virtualMachine ).
	self assert: (Canopy / #pharo / #virtualMachine / #memorySize) value isNumber ]
		ensure: [ Canopy reset ]
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testRegisterVirtualMachineMetricsRegistersTheVirtualMachineHalfUnderPharo [
	"See testRegisterImageMetricsRegistersTheImageHalfUnderPharo - the same for the other half."
	[ Canopy registerVirtualMachineMetrics.
	self assert: Canopy domainNames asArray equals: #( #pharo ).
	self assert: (Canopy / #pharo) keys asArray equals: #( #virtualMachine ) ]
		ensure: [ Canopy reset ]
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testSlashOnLeafRaisesError [
	| root |
	root := Canopy new.
	root at: #leaf put: (CanopyCell new value: 42).
	self should: [ (root / #leaf) / #anything ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testUseNewInstanceDuringPutsThePreviousTreeBack [
	"What a test needs that has to register domains of its own, and what #reset alone does not
	give: the tree that was there before comes back. These test classes travel into the server
	images, and AGTestRunnerHandler runs any suite in the image it is asked for over /health -
	a #reset there takes the tree the server is serving and nothing says so.

	Reset at both ends, and the leading one is not decoration: this test has to put something
	into the ambient tree to have something to get back, and the very leak it would otherwise
	leave behind is what it exists to prevent."
	| before during |
	[ Canopy reset.
	before := Canopy instance.
	before at: #somethingTheServerServes put: (CanopyCell new value: 1).
	Canopy useNewInstanceDuring: [
		during := Canopy instance.
		Canopy registerDomainNamed: #mine with: CanopyBranchNode new ].
	self deny: during identicalTo: before.
	self assert: Canopy instance identicalTo: before.
	self assert: (Canopy / #somethingTheServerServes) value equals: 1.
	self deny: (Canopy domainNames includes: #mine) ]
		ensure: [ Canopy reset ]
]
