Extension { #name : 'String' }

{ #category : '*GlobalTree-Core' }
String >> asGlobalTree [
	^ self readStream asGlobalTreeValue
]
