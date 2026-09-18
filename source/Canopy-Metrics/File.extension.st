Extension { #name : 'File' }

{ #category : '*Canopy-Metrics' }
File class >> canopyRegister [
	^ (Canopy /+ #pharo /+ #image) merge: (CanopyMappingBuilder new object: self; map: CanopyBranchNode new; build)
]

{ #category : '*Canopy-Metrics' }
File class >> fileRegistrySizeCanopy [
	<canopyValue: #fileRegistrySize>
	^ CanopyMetric new
		type: #gauge;
		description: 'The number of files registered';
		value: self registry size
]
