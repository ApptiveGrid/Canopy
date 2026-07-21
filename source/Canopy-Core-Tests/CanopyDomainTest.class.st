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
	top-level domains should use registerDomain:with: instead (see testRegisterDomainRaisesOnCollisionAndDoesNotOverwrite).
	This test documents that at:put: itself still silently overwrites."
	| root replacement |
	root := Canopy new.
	root at: #image put: (CanopyCell new value: 'original').
	replacement := CanopyCell new value: 'replaced'.
	root at: #image put: replacement.
	self assert: (root / #image) value equals: 'replaced'
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testAttachSystemMetricsRegistersImageAndVirtualMachineDomains [
	"attachSystemMetrics is an explicit opt-in, not an automatic image-startup hook (Norbert,
	2026-07-21: not everyone wants this without being asked) - a caller invokes it themselves."
	[ Canopy attachSystemMetrics.
	self assertCollection: Canopy domains asArray hasSameElements: #( #image #virtualMachine ) ]
		ensure: [ Canopy reset ]
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testDomainsListsAllRegisteredDomains [
	| root |
	root := Canopy new.
	root registerDomain: #image with: (CanopyCell new value: 1).
	root registerDomain: #virtualMachine with: (CanopyCell new value: 2).
	self assertCollection: root domains asArray hasSameElements: #( #image #virtualMachine )
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testEnsureAtCreatesMissingBranch [
	| root |
	root := Canopy new.
	self assert: (root /+ #newDomain) class equals: CanopyBranchNode.
	self assert: (root / #newDomain) class equals: CanopyBranchNode
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
CanopyDomainTest >> testRegisterDomainAddsNewDomain [
	| root |
	root := Canopy new.
	root registerDomain: #image with: (CanopyCell new value: 1).
	self assert: (root / #image) value equals: 1.
	self assert: root domains asArray equals: #( #image )
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testRegisterDomainRaisesOnCollisionAndDoesNotOverwrite [
	| root |
	root := Canopy new.
	root registerDomain: #image with: (CanopyCell new value: 1).
	self should: [ root registerDomain: #image with: (CanopyCell new value: 2) ] raise: Error.
	self assert: (root / #image) value equals: 1
]

{ #category : 'as yet unclassified' }
CanopyDomainTest >> testSlashOnLeafRaisesError [
	| root |
	root := Canopy new.
	root at: #leaf put: (CanopyCell new value: 42).
	self should: [ (root / #leaf) / #anything ] raise: Error
]
