Extension { #name : 'Object' }

{ #category : '*GlobalTree-Core' }
Object >> asGlobalTreeValue [
	^ GlobValueHolder new value: self 
]

{ #category : '*GlobalTree-Core' }
Object >> globalTreeBind: aPTGroup keys: aCollection [ 
	aCollection do: [ :accessor |
		(aPTGroup at: accessor) register: (GlobAccessor new 
			object: self;
			selector: accessor) ]
]
