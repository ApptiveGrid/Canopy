Extension { #name : 'VirtualMachine' }

{ #category : '*Canopy-Metrics' }
VirtualMachine class >> canopyRegister [
	^ (Canopy /+ #pharo /+ #virtualMachine) merge: (CanopyMappingBuilder new object: Smalltalk vm; map: CanopyBranchNode new; build)
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> edenSpaceSizeCanopy [
	<canopyValue: #edenSpaceSize>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of eden (new space) in bytes';
		value: self edenSpaceSize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> extraVMMemoryCanopy [
	<canopyValue: #extraVMMemory>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of extra memory allocated on the heap';
		value: self extraVMMemory
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> freeOldSpaceSizeCanopy [
	<canopyValue: #freeOldSpaceSize>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of freed memory from old space';
		value: self freeOldSpaceSize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> fullGCCountCanopy [
	<canopyValue: #fullGCCount>
	^ CanopyMetric new
		type: #counter;
		description: 'The amount of full garbage collection runs';
		value: self fullGCCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> incrementalGCCountCanopy [
	<canopyValue: #incrementalGCCount>
	^ CanopyMetric new
		type: #counter;
		description: 'The amount of incremental garbage collection runs';
		value: self incrementalGCCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> maxExternalSemaphoresCanopy [
	<canopyValue: #maxExternalSemaphores>
	^ CanopyMetric new
		type: #gauge;
		description: 'The maximum of available external semaphores';
		value: self  maxExternalSemaphores
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> maxExternalSemaphoresCanopy: anInteger [
	"The same key as the reading declaration above: one leaf that can be read and written,
	instead of the same value sitting twice in the tree under two names."
	<canopyValue: #maxExternalSemaphores>
	^ self maxExternalSemaphoresSilently: anInteger
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> memoryEndCanopy [
	<canopyValue: #memoryEnd>
	^ CanopyMetric new
		type: #gauge;
		description: 'The end of memory';
		value: self memoryEnd 
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> memorySizeCanopy [
	<canopyValue: #memorySize>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of memory';
		value: self memorySize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> oldSpaceCanopy [
	<canopyValue: #oldSpace>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of old space';
		value: self oldSpace
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> oldSpaceEndCanopy [
	<canopyValue: #oldSpaceEnd>
	^ CanopyMetric new
		type: #gauge;
		description: 'The end of old space';
		value: self oldSpaceEnd
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> tenureCountCanopy [
	<canopyValue: #tenureCount>
	^ CanopyMetric new
		type: #counter;
		description: 'The amount of tenured objects';
		value: self tenureCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> totalFullGCTimeCanopy [
	<canopyValue: #totalFullGCTime>
	^ CanopyMetric new
		type: #gauge;
		description: 'The amount of time for a full GC';
		value: self totalFullGCTime
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> totalIncrementalGCTimeCanopy [
	<canopyValue: #totalIncrementalGCTime>
	^ CanopyMetric new
		type: #gauge;
		description: 'The amount of time for a incremental GC';
		value: self totalIncrementalGCTime
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> youngSpaceEndCanopy [
	<canopyValue: #youngSpaceEnd>
	^ CanopyMetric new
		type: #gauge;
		description: 'The end of young space';
		value: self youngSpaceEnd
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> youngSpaceSizeCanopy [
	<canopyValue: #youngSpaceSize>
	^ CanopyMetric new
		type: #gauge;
		description: 'The size of young space';
		value: self youngSpaceSize
]
