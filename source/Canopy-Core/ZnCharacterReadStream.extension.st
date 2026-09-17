Extension { #name : 'ZnCharacterReadStream' }

{ #category : '*Canopy-Core' }
ZnCharacterReadStream >> asCanopyNode [
	^ (STON fromStream: self) asCanopyNode
]
