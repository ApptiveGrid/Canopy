Extension { #name : 'Dictionary' }

{ #category : '*Canopy-Core' }
Dictionary >> asCanopyNode [
	"A Dictionary is structure, not a value: it becomes a branch with one node per key, recursively."
	| group |
	group := CanopyBranchNode new.
	self keysAndValuesDo: [ :key :value |
		group at: key put: value asCanopyNode ].
	^ group
]

{ #category : '*Canopy-Core' }
Dictionary >> canopyBranch: aBuilder [
	<canopyBranch>
	self keysAndValuesDo: [ :key :value |
		aBuilder at: key addMapping: value ]
]
