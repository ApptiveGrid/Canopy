Extension { #name : 'File' }

{ #category : '*Canopy-Metrics' }
File class >> canopyRegister [
	^ (Canopy /+ #image) merge: (CanopyMappingBuilder new object: self; map: CanopyBranchNode new; build)
]

{ #category : '*Canopy-Metrics' }
File class >> fileRegistrySizeCanopy [
	<canopyValue: #fileRegistrySize type: #metric arguments: #('The number of files registered' gauge)>
	^ self registry size
]
