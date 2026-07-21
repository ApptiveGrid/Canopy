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
CanopyMergeTest >> testDictionaryAccessorValueReturnsWrappedDictionary [
	"Previously missing (see Canopy roadmap): without it, value/inspectionValue
	silently fell back to Object>>value (returns self) instead of DNU-ing,
	which is misleading in the debugger/inspector - not a crash, but wrong."
	| dict target |
	dict := Dictionary new.
	target := CanopyDictionaryAccessor on: dict.
	self assert: target value == dict.
	self assert: target inspectionValue == dict
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
CanopyMergeTest >> testDictionaryApplyWithTagOnlyAppliesWhenBranchTagMatches [
	| branch dict target |
	branch := CanopyBranchNode new.
	branch at: #a put: (CanopyCell new value: 1).
	branch addTag: #config.
	dict := Dictionary new.
	target := CanopyDictionaryAccessor on: dict.
	target apply: branch withTag: #metrics.
	self deny: (dict includesKey: #a).
	target apply: branch withTag: #config.
	self assert: (dict at: #a) equals: 1
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testMergingAccessorIntoAccessorRaisesConflict [
	"Verified 2026-07-21: two accessors bound to different live objects have no defined merge
	semantics - raises a controlled conflict instead of a raw MessageNotUnderstood."
	| existing incoming |
	existing := CanopyAccessor new.
	incoming := CanopyAccessor new.
	self should: [ existing merge: incoming ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testMergingAccessorIntoBranchRaisesConflict [
	"Verified 2026-07-21: before the fix this crashed with a raw MessageNotUnderstood
	(#mergeInto:) instead of a controlled conflict - CanopyAccessor has no defined merge
	semantics, merging one into anything never makes sense."
	| existing incoming |
	existing := CanopyBranchNode new at: #a put: (CanopyCell new value: 1); yourself.
	incoming := CanopyAccessor new.
	self should: [ existing merge: incoming ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testMergingBranchIntoAccessorRaisesConflict [
	"Verified 2026-07-21 (Canopy backlog, weitere asymmetrische Typkombinationen): before the
	fix this crashed with a raw MessageNotUnderstood (#at:add:) instead of a controlled
	conflict - CanopyAccessor has no defined merge semantics, merging into it never makes sense."
	| existing incoming |
	existing := CanopyAccessor new.
	incoming := CanopyBranchNode new at: #a put: (CanopyCell new value: 1); yourself.
	self should: [ existing merge: incoming ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testMergingBranchIntoCellRaisesConflict [
	"Fixed 2026-07-21 (Canopy backlog, Merge-Konflikt-Asymmetrie beheben): CanopyCell>>merge:
	now raises a controlled conflict error when the incoming node is not itself a CanopyCell,
	instead of silently falling back to Object>>value (which returned the incoming branch
	node itself, corrupting the existing cell). Mirrors the existing Cell->Branch conflict
	from testMergingCellIntoBranchRaisesConflict in the other direction. Was previously
	testMergingBranchIntoCellIsNotDetectedAsConflict, a characterization test for this gap."
	| existing incoming |
	existing := Canopy new.
	existing at: #foo put: (CanopyCell new value: 42).
	incoming := Canopy new.
	incoming at: #foo put: CanopyBranchNode new.
	self should: [ existing merge: incoming ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testMergingBranchIntoDictionaryAccessorRaisesConflict [
	"Same fix, different leaf subtype - confirms the CanopyLeafNode>>mergeInto:/
	CanopyBranchNode>>mergeInto: guard covers CanopyDictionaryAccessor too, not just
	CanopyAccessor."
	| existing incoming |
	existing := CanopyDictionaryAccessor new.
	incoming := CanopyBranchNode new at: #a put: (CanopyCell new value: 1); yourself.
	self should: [ existing merge: incoming ] raise: Error
]

{ #category : 'as yet unclassified' }
CanopyMergeTest >> testMergingCellIntoBranchRaisesConflict [
	"Verified 2026-07-16: CanopyCell>>mergeInto: raises a controlled conflict error when an
	incoming CanopyCell is merged into an existing CanopyBranchNode at the same key. Error
	message typo ('cponflict') fixed 2026-07-21, see Canopy backlog, Merge-Konflikt-
	Asymmetrie beheben. See Canopy doc.md, Fehlerklassen."
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
