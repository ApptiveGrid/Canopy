Extension { #name : 'ExternalSemaphoreTable' }

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> externalObjectTableSizeCanopy [
	<canopyValue: #externalObjectTableSize type: #metric arguments: #('The number of registered external objects' gauge)>
	^ self externalObjects size
]

{ #category : '*Canopy-Metrics' }
ExternalSemaphoreTable class >> externalObjectsCanopy [ 
	<canopyValue: #externalObjects type: #metric arguments: #('The number of registered external objects' gauge)>
	^ (self externalObjects reject: #isNil) size
]
