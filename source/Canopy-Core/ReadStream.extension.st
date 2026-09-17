Extension { #name : 'ReadStream' }

{ #category : '*Canopy-Core' }
ReadStream >> asCanopyNode [
	^ (STON fromStream: self) asCanopyNode
]
