Extension { #name : 'ZnCharacterReadStream' }

{ #category : '*Canopy-Core' }
ZnCharacterReadStream >> asCanopyCell [
	^ (STON fromStream: self) asCanopyCell
]
