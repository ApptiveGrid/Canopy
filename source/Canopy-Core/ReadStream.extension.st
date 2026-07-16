Extension { #name : 'ReadStream' }

{ #category : '*Canopy-Core' }
ReadStream >> asCanopyCell [
	^ (STON fromStream: self) asCanopyCell
]
