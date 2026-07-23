Extension { #name : 'SmalltalkImage' }

{ #category : '*Canopy-Metrics' }
SmalltalkImage class >> canopyRegister [
	^ (Canopy /+ #image) merge: (CanopyMappingBuilder new object: Smalltalk; map: CanopyBranchNode new; build)
]
