Extension { #name : 'ExternalSemaphoreTable' }

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> canopyRegister [
	^ (Canopy /+ #image) merge: (CanopyMappingBuilder new object: self; map: CanopyBranchNode new; build)
]

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> externalObjectTableSizeCanopy [
	<canopyValue: #externalObjectTableSize type: #metric arguments: #('The total size of the external object table, including free slots' gauge)>
	^ self externalObjects size
]

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> externalObjectsCanopy [
	<canopyValue: #externalObjects type: #metric arguments: #('The number of currently registered (non-nil) external objects' gauge)>
	^ (self externalObjects reject: #isNil) size
]
