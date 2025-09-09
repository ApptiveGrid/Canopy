Extension { #name : 'Dictionary' }

{ #category : '*Canopy-Core' }
Dictionary >> asCanopyValue [
	| group |
	group := CanopyBranchNode new.
	
	self keysAndValuesDo: [ :key :value |
		group at: key put: value asCanopyValue ].
	^ group 
]

{ #category : '*Canopy-Core' }
Dictionary >> canopyMapping: aBuilder [
	<canopyMapping>
	
	self keysAndValuesDo: [ :key :value |
		aBuilder at: key addMapping: value  ]
]
