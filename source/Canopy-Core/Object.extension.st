Extension { #name : 'Object' }

{ #category : '*Canopy-Core' }
Object >> asCanopyValue [
	^ CanopyValue new value: self 
]

{ #category : '*Canopy-Core' }
Object >> canopyBind: aPTGroup keys: aCollection [ 
	aCollection do: [ :accessor |
		(aPTGroup at: accessor) register: (CanopyAccessor new 
			object: self;
			selector: accessor) ]
]

{ #category : '*Canopy-Core' }
Object >> canopyMapping [
	^ CanopyMappingBuilder new 
		object: self;
		map: CanopyBranchNode new;
		build
]
