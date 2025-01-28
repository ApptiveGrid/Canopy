Extension { #name : 'File' }

{ #category : '*Canopy-Metrics' }
File class >> fileRegistrySizeCanopy [
	<canopyValue: #fileRegistrySize type: #metric arguments: #('The number of files registered' gauge)>
	^ self registry size
]
