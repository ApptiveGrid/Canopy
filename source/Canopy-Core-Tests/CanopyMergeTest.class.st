Class {
	#name : 'CanopyMergeTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testCellMergeAccumulatesTags [
	| existing incoming |
	existing := CanopyCell new value: 1; tags: (Set withAll: #(a)); yourself.
	incoming := CanopyCell new value: 2; tags: (Set withAll: #(b)); yourself.
	existing merge: incoming.
	self assertCollection: existing tags hasSameElements: #(a b)
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testCellMergeOverwritesWithLastValue [
	| existing incoming |
	existing := CanopyCell new value: 1.
	incoming := CanopyCell new value: 2.
	existing merge: incoming.
	self assert: existing value equals: 2
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testDictionaryApplyPushesValuesByKey [
	| branch dict target |
	branch := CanopyBranchNode new.
	branch at: #a put: (CanopyCell new value: 1).
	branch at: #b put: (CanopyCell new value: 2).
	dict := Dictionary new.
	target := CanopyDictionaryAccessor on: dict.
	target apply: branch.
	self assert: (dict at: #a) equals: 1.
	self assert: (dict at: #b) equals: 2
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testMergingBranchIntoCellIsNotDetectedAsConflict [
	"Known rough edge, see Canopy doc.md 'Fehlerklassen & bekannte Rough Edges': the reverse
	case does NOT raise an error. CanopyCell>>merge: calls aGlobNode value, which falls back
	to Object>>value (returns self) for a CanopyBranchNode - the existing cell silently ends
	up holding the incoming branch node itself instead of a raw value. Characterization test:
	documents CURRENT (arguably broken) behavior, not desired behavior."
	| existing incoming |
	existing := Canopy new.
	existing at: #foo put: (CanopyCell new value: 42).
	incoming := Canopy new.
	incoming at: #foo put: CanopyBranchNode new.
	existing merge: incoming.
	self assert: (existing / #foo) value == (incoming / #foo)
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testMergingCellIntoBranchRaisesConflict [
	"Verified 2026-07-16: CanopyCell>>mergeInto: raises a controlled conflict error
	('cponflict', typo in the source) when an incoming CanopyCell is merged into an
	existing CanopyBranchNode at the same key. See Canopy doc.md, Fehlerklassen."
	| existing incoming |
	existing := Canopy new.
	existing at: #foo put: CanopyBranchNode new.
	incoming := Canopy new.
	incoming at: #foo put: (CanopyCell new value: 42).
	self should: [ existing merge: incoming ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testNonOverlappingKeysSurviveAcrossReimport [
	| tree |
	tree := Canopy new importTree: '{ "one" : 1 }'.
	tree importTree: '{ "two" : 2 }'.
	self assert: (tree / #one) value equals: 1.
	self assert: (tree / #two) value equals: 2
]
