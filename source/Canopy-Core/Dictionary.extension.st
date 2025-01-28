Extension { #name : 'Dictionary' }

{ #category : '*Canopy-Core' }
Dictionary >> asCanopyValue [
	| group |
	group := CanopyBranchNode new.
	
	self keysAndValuesDo: [ :key :value |
		group at: key put: value asCanopyValue ].
	^ group 
]
