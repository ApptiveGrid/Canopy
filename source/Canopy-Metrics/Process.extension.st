Extension { #name : 'Process' }

{ #category : '*Canopy-Metrics' }
Process class >> activeProcessListCanopy [ 
	<canopyValue: #processesActive type: #metric arguments: #('The number of active processes' gauge)>
	^ (self allSubInstances reject: #isTerminated) size
]

{ #category : '*Canopy-Metrics' }
Process class >> terminatedProcessListCanopy [
	<canopyValue: #processesTerminated type: #metric arguments: #('The number of terminated processes' gauge)>
	^ (self allSubInstances select: #isTerminated) size
]
