Extension { #name : 'ExternalSemaphoreTable' }

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> canopyRegister [
	^ (Canopy /+ #image) merge: (CanopyMappingBuilder new object: self; map: CanopyBranchNode new; build)
]

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> externalObjectTableSizeCanopy [
	<canopyValue: #externalObjectTableSize type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The total size of the external object table, including free slots';
		value: self externalObjects size
]

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> externalObjectsCanopy [
	<canopyValue: #externalObjects type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The number of currently registered (non-nil) external objects';
		value: (self externalObjects reject: #isNil) size
]
