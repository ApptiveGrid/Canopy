Extension { #name : 'FileReference' }

{ #category : '*Canopy-Core' }
FileReference >> asCanopy [
	^ self readStream asCanopyValue
]
