Class {
	#name : 'CanopyAccessorTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testALeafCanReadFromABlockInsteadOfAComponent [
	"Runtime values have no pragma to declare them - the block is the object and evaluating it is
	the read. The value stays live, which is the whole point: it is worked out per scrape."
	| count leaf |
	count := 0.
	leaf := CanopyAccessor reading: [ count ].
	self assert: leaf value equals: 0.
	count := 42.
	self assert: leaf value equals: 42
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testAcceptCanopySkipsWriteOnlyAccessorsInsteadOfCrashing [
	"Found 2026-07-21 while sanity-checking format: over the real Canopy systemMetrics
	tree: VirtualMachine>>maxExternalSemaphoresCanopy: is a write-only declaration
	pragma sitting in the same tree as real #metric values under #virtualMachine. Before
	this fix, acceptCanopy: unconditionally dispatched to visitMetric:, which crashed on
	nil name/description for any write-only accessor. Write-only accessors must not break
	formatting of a tree they happen to be mixed into."
	| root writeOnly output |
	root := CanopyBranchNode new.
	writeOnly := CanopyAccessor new object: CanopyTestObject new; writeSelector: #one; yourself.
	root at: #writeOnlyThing put: writeOnly.
	output := CanopyPrometheusVisitor new format: root.
	self assert: output isEmpty
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testASubtreeReachesAComponentThroughAnOrdinaryWriteDeclaration [
	"The sink used to need a node class of its own and a type in the pragma. It is an ordinary
	one-argument declaration now, and what it receives is a plain nested Dictionary."
	| object built |
	object := CanopyDictionaryTestObject new settings: (Dictionary new at: #a put: 1; yourself); yourself.
	built := CanopyMappingBuilder new object: object; map: CanopyBranchNode new; build.
	(built / #settings) apply: (CanopyBranchNode new at: #b put: (CanopyCell new value: 2); yourself).
	self assert: (object settings at: #a) equals: 1.
	self assert: (object settings at: #b) equals: 2
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testAUnaryDeclarationBuildsAReadOnlyLeaf [
	"A declaration on a method that answers a value can only read: the leaf has a read selector
	and no write selector, without anything in the pragma saying so."
	| object built leaf |
	object := CanopyTestObject new.
	object one: 42.
	built := CanopyMappingBuilder new object: object; map: CanopyBranchNode new; build.
	leaf := built / #one.
	self assert: leaf class equals: CanopyAccessor.
	self assert: leaf value equals: 42.
	self should: [ leaf value: 1 ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testTwoDeclarationsForOneKeyBecomeOneReadWriteLeaf [
	"A getter and a setter declared under the same key are two pragmas and one node. Until the
	direction came from the arity this could not be declared at all, although the leaf had been
	able to do both since the accessor and the metric were unified."
	| object built leaf |
	object := CanopyRootTestObject new.
	object one: 42.
	built := CanopyMappingBuilder new object: object; map: CanopyBranchNode new; build.
	leaf := built / #one.
	self assert: leaf value equals: 42.
	leaf value: 99.
	self assert: object one equals: 99.
	self assert: leaf value equals: 99
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testTwoDeclarationsInTheSameDirectionFailLoudly [
	"Two declarations writing the same key used to overwrite each other silently, and which of
	them survived fell out of the order the pragmas were collected in - the same mistake sat in
	apptive-account and apptive-base for a year and resolved differently in each."
	self
		should: [ CanopyMappingBuilder new object: CanopyDuplicateDeclarationExample new; map: CanopyBranchNode new; build ]
		raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testReadAndWriteSelectorsWorkIndependentlyOnTheSameInstance [
	"The whole point of the unification: one leaf type, read and write are just optional
	selectors, not separate classes. Read and write here intentionally target different
	object properties to prove they are independent, not coupled."
	| object accessor |
	object := CanopyTestObject new.
	object one: 1; two: 2.
	accessor := CanopyAccessor new
		object: object;
		readSelector: #one;
		writeSelector: #two;
		yourself.
	self assert: accessor value equals: 1.
	accessor value: 99.
	self assert: object two equals: 99.
	self assert: object one equals: 1 "read selector target is untouched by the write"
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testValueRaisesControlledErrorWhenNoReadSelector [
	"Fixed 2026-07-21 (Accessor/Metric-Vereinheitlichung): previously value was simply
	undefined for a write-only accessor - would raise a raw doesNotUnderstand if ever
	visited/read. Now a controlled error, matching the merge-conflict philosophy elsewhere."
	self should: [ CanopyAccessor new value ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testValueStaysRawWhileValueHolderAnswersTheHolder [
	"The holder is invisible to every reader but the export path: value unwraps it, valueHolder
	does not. That is what keeps apply:, the JSON visitor and the browse handler untouched."
	| accessor |
	accessor := CanopyAccessor new
		object: (CanopyTestObject new one: 42; yourself);
		readSelector: #one;
		yourself.
	self assert: accessor value equals: 42.
	self assert: accessor valueHolder class equals: CanopyValue.
	self assert: accessor valueHolder value equals: 42
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testValueUnwrapsAHolderOnTheWayIn [
	"Written values are unwrapped in exactly one place, here - so the component's own write
	method keeps receiving a raw value and never has to know that holders exist."
	| object accessor |
	object := CanopyTestObject new.
	accessor := CanopyAccessor new
		object: object;
		writeSelector: #one;
		yourself.
	accessor value: 99 asCanopyValue.
	self assert: object one equals: 99
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testValueWriteRaisesControlledErrorWhenNoWriteSelector [
	"Mirrors the old CanopyMetric>>value: ('a metric cannot be written') - a read-only
	accessor now raises the same kind of controlled error for the opposite direction."
	self should: [ CanopyAccessor new value: 5 ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testTheSameDeclarationMergedAgainIsNotAConflict [
	"The narrow case that lets a class register itself twice: same object, same selectors.
	There is nothing to merge, so nothing happens - as opposed to the two cases below, where
	two different things want the same place and the conflict is real."
	| object left right |
	object := CanopyRootTestObject new.
	left := CanopyAccessor new object: object; readSelector: #one; yourself.
	right := CanopyAccessor new object: object; readSelector: #one; yourself.
	self shouldnt: [ left merge: right ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testTwoAccessorsOnDifferentObjectsStillConflict [
	"Two objects that are equal but not the same declare two different things."
	| left right |
	left := CanopyAccessor new object: CanopyRootTestObject new; readSelector: #one; yourself.
	right := CanopyAccessor new object: CanopyRootTestObject new; readSelector: #one; yourself.
	self should: [ left merge: right ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testTwoAccessorsReadingThroughDifferentSelectorsStillConflict [
	| object left right |
	object := CanopyRootTestObject new.
	left := CanopyAccessor new object: object; readSelector: #one; yourself.
	right := CanopyAccessor new object: object; readSelector: #printString; yourself.
	self should: [ left merge: right ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testTwoAccessorsThatDeclareNothingStillConflict [
	"Two empty accessors are not one declaration made twice - they are no declaration at all,
	and CanopyMergeTest has said so since 2026-07-21. Written down here too, because it is the
	one case the repeat-tolerance above must not swallow."
	self should: [ CanopyAccessor new merge: CanopyAccessor new ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyAccessorTest >> testEveryBranchMethodContributes [
	"Two methods carrying <canopyBranch> and both of them build. Until 2026-09-21 the builder
	ran the marked method only when there was exactly one, so a second one did not add a
	branch - it removed the first, silently and without an else."
	| tree |
	tree := CanopyTwoBranchExample new canopyMapping.
	self assert: (tree / #first) value equals: 1.
	self assert: (tree / #second) value equals: 2
]
