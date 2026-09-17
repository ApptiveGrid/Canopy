Extension { #name : 'ExternalSemaphoreTable' }

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> canopyRegister [
	"External semaphores are a virtual machine concept, and pharo-metrics exports them under
	#virtualMachine. Registering them under #image renamed two series without saying so."
	^ (Canopy /+ #virtualMachine) merge: (CanopyMappingBuilder new object: self; map: CanopyBranchNode new; build)
]

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> externalObjectTableSizeCanopy [
	<canopyValue: #externalObjectTableSize>
	^ CanopyMetric new
		type: #gauge;
		description: 'The total size of the external object table, including free slots';
		value: self externalObjects size
]

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> externalObjectsCanopy [
	<canopyValue: #externalObjects>
	^ CanopyMetric new
		type: #gauge;
		description: 'The number of currently registered (non-nil) external objects';
		value: (self externalObjects reject: #isNil) size
]
