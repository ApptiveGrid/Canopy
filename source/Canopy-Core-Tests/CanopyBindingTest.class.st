Class {
	#name : 'CanopyBindingTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testBindAfterValueIsSet [
	| tree object |
	tree := Canopy new importTree: '{ "one" : 42 }'.
	object := CanopyTestObject new.
	object canopyBind: tree keys: #( one ).
	self assert: object one equals: 42
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testCanopySetupFromBindsAndAppliesConfig [
	"Covers the declarative entry point Object>>canopySetupFrom: - builds the
	receiver's own component tree via pragma reflection and applies the given
	config object onto it in one call. Previously untested, see Canopy roadmap."
	| object |
	object := CanopyRootTestObject new.
	object canopySetupFrom: '{ "one" : 42 }'.
	self assert: object one equals: 42
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testCanopySetupFromFileBindsAndAppliesConfig [
	"Covers the declarative entry point Object>>canopySetupFromFile: - same as
	canopySetupFrom:, but reading the config from an actual file on disk."
	| object file |
	file := FileLocator temp / 'canopy-setup-test.json'.
	file writeStreamDo: [ :stream | stream nextPutAll: '{ "one" : 42 }' ].
	object := CanopyRootTestObject new.
	[ object canopySetupFromFile: file fullName ]
		ensure: [ file ensureDelete ].
	self assert: object one equals: 42
]

{ #category : 'tests' }
CanopyBindingTest >> testBindProperties [
	| tree object |
	tree := Canopy new importTree: '{ "first" : { "second" : { "one" : 1, "two": 2, "three" : 3 }}}'.
	object := CanopyTestObject new
		canopyBind: tree / #first / #second keys: #( one two three ).
	self assert: object one equals: 1.
	self assert: object two equals: 2.
	self assert: object three equals: 3
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testHotReloadNotPropagatedToBoundObject [
	"Fixed 2026-07-17: CanopyCell>>value: now notifies a registered dependent accessor."
	| tree object |
	tree := Canopy new.
	tree at: #one put: CanopyCell new.
	object := CanopyTestObject new.
	object canopyBind: tree keys: #( one ).
	(tree / #one) value: 42.
	self assert: object one equals: 42
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testHotReloadViaReimport [
	"Fixed 2026-07-17: CanopyCell>>register: now always tracks dependents, regardless of
	whether a value already existed at bind time."
	| tree object |
	tree := Canopy new importTree: '{ "one" : 1 }'.
	object := CanopyTestObject new.
	object canopyBind: tree keys: #( one ).
	self assert: object one equals: 1.
	tree importTree: '{ "one" : 2 }'.
	self assert: object one equals: 2
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testMultipleAccessorRegistrationsAreAllNotified [
	"Fixed 2026-07-17: CanopyCell>>register: now keeps a dependents collection instead of a
	single slot - both accessors registered before a value exists are notified once it is set."
	| value accessorA accessorB objectA objectB |
	value := CanopyCell new.
	objectA := CanopyTestObject new.
	objectB := CanopyTestObject new.
	accessorA := CanopyAccessor new object: objectA; selector: #one; yourself.
	accessorB := CanopyAccessor new object: objectB; selector: #one; yourself.
	value register: accessorA.
	value register: accessorB.
	value value: 99.
	self assert: objectA one equals: 99.
	self assert: objectB one equals: 99
]

{ #category : 'as yet unclassified' }
CanopyBindingTest >> testSetupConfigurationBindsPortFromTestServerDomain [
	"Regression test for the fixed Canopy apptiveGrid placeholder bug (see Canopy roadmap,
	Bekannter Bug/Platzhalter: Canopy apptiveGrid nicht definiert). apptiveGrid was never a
	real domain - it silently resolved to the unrelated Object>>apptiveGrid accessor from
	Apptive-Common-Core and returned nil instead of raising. Fixed by using the actual
	#testServer domain this class represents."
	| server |
	[ ((Canopy /+ #testServer) /+ #httpServer) at: #port put: (CanopyCell new value: 8080).
	server := CanopyTestServer new.
	server setupConfiguration.
	self assert: server port equals: 8080 ]
		ensure: [ Canopy reset ]
]
