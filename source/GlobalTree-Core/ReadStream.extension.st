Extension { #name : 'ReadStream' }

{ #category : '*GlobalTree-Core' }
ReadStream >> asGlobalTreeValue [
	^ (STON fromStream: self) asGlobalTreeValue 
]
