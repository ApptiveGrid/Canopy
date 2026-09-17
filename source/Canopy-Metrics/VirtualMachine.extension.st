Extension { #name : 'VirtualMachine' }

{ #category : '*Canopy-Metrics' }
VirtualMachine class >> canopyRegister [
	^ Canopy registerDomainNamed: #virtualMachine with: (CanopyMappingBuilder new object: Smalltalk vm; map: CanopyBranchNode new; build)
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> edenSpaceSizeCanopy [
	<canopyValue: #edenSpaceSize type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of eden (new space) in bytes';
		value: self edenSpaceSize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> extraVMMemoryCanopy [
	<canopyValue: #extraVMMemory type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of extra memory allocated on the heap';
		value: self extraVMMemory
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> freeOldSpaceSizeCanopy [
	<canopyValue: #freeOldSpaceSize type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of freed memory from old space';
		value: self freeOldSpaceSize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> fullGCCountCanopy [
	<canopyValue: #fullGCCount type: #metric arguments: #()>
	^ CanopyMetric new
		type: #counter;
		description: 'The amount of full garbage collection runs';
		value: self fullGCCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> incrementalGCCountCanopy [
	<canopyValue: #incrementalGCCount type: #metric arguments: #()>
	^ CanopyMetric new
		type: #counter;
		description: 'The amount of incremental garbage collection runs';
		value: self incrementalGCCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> maxExternalSemaphoresCanopy [
	<canopyValue: #maxExternalSemaphores type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The maximum of available external semaphores';
		value: self  maxExternalSemaphores
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> maximumExternalSemaphoresCanopy: anInteger [
	<canopyValue: #maximumExternalSemaphores type: #accessor arguments: #()>
	^ self maxExternalSemaphoresSilently: anInteger 
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> memoryEndCanopy [
	<canopyValue: #memoryEnd type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The end of memory';
		value: self memoryEnd 
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> memorySizeCanopy [
	<canopyValue: #memorySize type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of memory';
		value: self memorySize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> oldSpaceCanopy [
	<canopyValue: #oldSpace type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of old space';
		value: self oldSpace
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> oldSpaceEndCanopy [
	<canopyValue: #oldSpaceEnd type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The end of old space';
		value: self oldSpaceEnd
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> tenureCountCanopy [
	<canopyValue: #tenureCount type: #metric arguments: #()>
	^ CanopyMetric new
		type: #counter;
		description: 'The amount of tenured objects';
		value: self tenureCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> totalFullGCTimeCanopy [
	<canopyValue: #totalFullGCTime type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The amount of time for a full GC';
		value: self totalFullGCTime
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> totalIncrementalGCTimeCanopy [
	<canopyValue: #totalIncrementalGCTime type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The amount of time for a incremental GC';
		value: self totalIncrementalGCTime
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> youngSpaceEndCanopy [
	<canopyValue: #youngSpaceEnd type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The end of young space';
		value: self youngSpaceEnd
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> youngSpaceSizeCanopy [
	<canopyValue: #youngSpaceSize type: #metric arguments: #()>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of young space';
		value: self youngSpaceSize
]
