Extension { #name : 'Object' }

{ #category : '*Canopy-Core' }
Object >> asCanopyCell [
	^ CanopyCell new value: self
]

{ #category : '*Canopy-Core' }
Object >> canopyBind: aPTGroup keys: aCollection [ 
	aCollection do: [ :accessor |
		(aPTGroup at: accessor) register: (CanopyAccessor new 
			object: self;
			writeSelector: accessor) ]
]

{ #category : '*Canopy-Core' }
Object >> canopyMapping [
	^ CanopyMappingBuilder new 
		object: self;
		map: CanopyBranchNode new;
		build
]

{ #category : '*Canopy-Core' }
Object >> canopySetupFrom: anObject [ 
	self canopyMapping 
		apply: anObject asCanopy 
]

{ #category : '*Canopy-Core' }
Object >> canopySetupFromFile: aString [ 
	self canopyMapping 
		apply: aString asFileReference asCanopy 
]
