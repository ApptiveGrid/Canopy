Extension { #name : 'ZnCharacterReadStream' }

{ #category : '*Canopy-Core' }
ZnCharacterReadStream >> asCanopyValue [ 
	^ (STON fromStream: self) asCanopyValue 
]
