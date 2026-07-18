Extension { #name : 'Dictionary' }

{ #category : '*Canopy-Core' }
Dictionary >> asCanopyCell [
	| group |
	group := CanopyBranchNode new.
	self keysAndValuesDo: [ :key :value |
		group at: key put: value asCanopyCell ].
	^ group
]

{ #category : '*Canopy-Core' }
Dictionary >> canopyBranch: aBuilder [
	<canopyBranch>
	self keysAndValuesDo: [ :key :value |
		aBuilder at: key addMapping: value ]
]
