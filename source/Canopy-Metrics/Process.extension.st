Extension { #name : 'Process' }

{ #category : '*Canopy-Metrics' }
Process class >> activeProcessListCanopy [ 
	<canopyValue: #processesActive>
	^ CanopyMetric new
		type: #gauge;
		description: 'The number of active processes';
		value: (self allSubInstances reject: #isTerminated) size
]

{ #category : '*Canopy-Metrics' }
Process class >> canopyRegister [
	^ (Canopy /+ #pharo /+ #image) merge: (CanopyMappingBuilder new object: self; map: CanopyBranchNode new; build)
]

{ #category : '*Canopy-Metrics' }
Process class >> terminatedProcessListCanopy [
	<canopyValue: #processesTerminated>
	^ CanopyMetric new
		type: #gauge;
		description: 'The number of terminated processes';
		value: (self allSubInstances select: #isTerminated) size
]
