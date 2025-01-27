Extension { #name : 'ReadStream' }

{ #category : '*Canopy-Core' }
ReadStream >> asCanopyValue [
	^ (STON fromStream: self) asCanopyValue 
]
