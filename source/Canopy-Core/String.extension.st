Extension { #name : 'String' }

{ #category : '*Canopy-Core' }
String >> asCanopy [
	^ self readStream asCanopyNode
]
