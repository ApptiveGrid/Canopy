Extension { #name : 'VirtualMachine' }

{ #category : '*Canopy-Metrics' }
VirtualMachine >> edenSpaceSizeCanopy [
	<canopyValue: #edenSpaceSize type: #metric arguments: #('The size of eden (new space) in bytes' gauge)>
	^ self edenSpaceSize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> extraVMMemoryCanopy [
	<canopyValue: #extraVMMemory type: #metric arguments: #('The size of extra memory allocated on the heap' gauge)>
	^ self extraVMMemory
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> freeOldSpaceSizeCanopy [
	<canopyValue: #freeOldSpaceSize type: #metric arguments: #('The size of freed memory from old space' gauge)>
	^ self freeOldSpaceSize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> fullGCCountCanopy [
	<canopyValue: #fullGCCount type: #metric arguments: #('The amount of full garbage collection runs' counter)>
	^ self fullGCCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> incrementalGCCountCanopy [
	<canopyValue: #incrementalGCCount type: #metric arguments: #('The amount of incremental garbage collection runs' counter)>
	^ self incrementalGCCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> maxExternalSemaphoresCanopy [
	<canopyValue: #maxExternalSemaphores type: #metric arguments: #('The maximum of available external semaphores' gauge)>
	^ self  maxExternalSemaphores
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> maximumExternalSemaphoresCanopy: anInteger [
	<canopyValue: #maximumExternalSemaphores type: #accessor arguments: #()>
	^ self maxExternalSemaphoresSilently: anInteger 
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> memoryEndCanopy [
	<canopyValue: #memoryEnd type: #metric arguments: #('The end of memory' gauge)>
	^ self memoryEnd 
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> memorySizeCanopy [
	<canopyValue: #memorySize type: #metric arguments: #('The size of memory' gauge)>
	^ self memorySize
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> oldSpaceCanopy [
	<canopyValue: #oldSpace type: #metric arguments: #('The size of old space' gauge)>
	^ self oldSpace
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> oldSpaceEndCanopy [
	<canopyValue: #oldSpaceEnd type: #metric arguments: #('The end of old space' gauge)>
	^ self oldSpaceEnd
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> tenureCountCanopy [
	<canopyValue: #tenureCount type: #metric arguments: #('The amount of tenured objects' counter)>
	^ self tenureCount
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> totalFullGCTimetCanopy [
	<canopyValue: #totalFullGCTime type: #metric arguments: #('The amount of time for a full GC' gauge)>
	^ self totalFullGCTime
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> totalIncrementalGCTimeCanopy [
	<canopyValue: #totalIncrementalGCTime type: #metric arguments: #('The amount of time for a incremental GC' gauge)>
	^ self totalIncrementalGCTime
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> youngSpaceEndCanopy [
	<canopyValue: #youngSpaceEnd type: #metric arguments: #('The end of young space' gauge)>
	^ self youngSpaceEnd
]

{ #category : '*Canopy-Metrics' }
VirtualMachine >> youngSpaceSizeCanopy [
	<canopyValue: #youngSpaceSize type: #metric arguments: #('The size of young space' gauge)>
	^ self youngSpaceSize
]
