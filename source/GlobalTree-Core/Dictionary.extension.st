Extension { #name : 'Dictionary' }

{ #category : '*GlobalTree-Core' }
Dictionary >> asGlobalTreeValue [
	| group |
	group := GlobBranch new.
	
	self keysAndValuesDo: [ :key :value |
		group at: key put: value asGlobalTreeValue ].
	^ group 
]
