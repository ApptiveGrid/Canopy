Class {
	#name : 'CanopyBranch',
	#superclass : 'CanopyNode',
	#instVars : [
		'nodes'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'copying' }
CanopyBranch >> , aGlobBranch [ 
	aGlobBranch mergeInto: self 
]

{ #category : 'arithmetic' }
CanopyBranch >> / aString [ 
	^ self at: aString 
]

{ #category : 'arithmetic' }
CanopyBranch >> /+ aString [ 
	^ self ensureAt: aString 
]

{ #category : 'composition' }
CanopyBranch >> @ aSymbol [
	^ (self at: aSymbol) value  
]

{ #category : 'target resize' }
CanopyBranch >> apply: aGlobBranch [ 
	aGlobBranch keysAndValuesDo: [ :key : value |
		(value isKindOf: CanopyBranch)
			ifTrue: [ (nodes at: key) apply: value ]
			ifFalse: [ (nodes at: key) value: value value ]
		 ]
]

{ #category : 'accessing' }
CanopyBranch >> at: key [ 
	^ nodes 
		at: key 
		ifAbsent: [ NotFound signal: 'cannot find key ', key asString , ' in ', self printString ]
]

{ #category : 'accessing' }
CanopyBranch >> at: aString add: aGlobBranch [ 
	nodes  
		at: aString 
		ifPresent: [ :value | value merge: aGlobBranch ]
		ifAbsent: [ self at: aString put: aGlobBranch ]
]

{ #category : 'accessing' }
CanopyBranch >> at: aString ifAbsent: aBlock [ 
	^ nodes 
		at: aString 
		ifAbsent: aBlock 
]

{ #category : 'accessing' }
CanopyBranch >> at: key put: value [ 
	(value isKindOf: CanopyNode) ifTrue: [  
		value parent: self ].
	nodes at: key put: value.
	^ value 
]

{ #category : 'accessing' }
CanopyBranch >> ensureAt: key [ 
	^ nodes 
		at: key 
		ifAbsent: [ 
			self at: key put: CanopyBranch new ]
]

{ #category : 'as yet unclassified' }
CanopyBranch >> importTree: anObject [ 
	self 
		importTree: anObject tags: #()
]

{ #category : 'as yet unclassified' }
CanopyBranch >> importTree: anObject tags: aCollection [
	| tree |
	tree := anObject asCanopy.
	tree recursiveDo: [ :each | each addTags: aCollection ].
	self merge: tree.
	"tree keys do: [ :key | 
		self at: key put: (tree at: key) ].
	tree addTags: aCollection."
	^ tree
]

{ #category : 'initialization' }
CanopyBranch >> initialize [ 
	super initialize.
	nodes := Dictionary new 
]

{ #category : 'inspector' }
CanopyBranch >> inspectionEntries [
	<inspectorPresentationOrder: 0 title: 'global branch'>

	^ SpTablePresenter new
		items: nodes values;
		addColumn: (SpStringTableColumn new
			title: 'key'";
			width: 30";
			evaluated: [:each | each inspectionLabel  ])
]

{ #category : 'accessing' }
CanopyBranch >> inspectionLabel [
	^ self key 
]

{ #category : 'as yet unclassified' }
CanopyBranch >> keyOf: aGlobBranch [ 
	^ nodes keyAtValue: aGlobBranch 
]

{ #category : 'accessing' }
CanopyBranch >> keys [
	^ nodes keys 
]

{ #category : 'enumerating' }
CanopyBranch >> keysAndValuesDo: aBlock [ 
	^ nodes keysAndValuesDo: aBlock 
]

{ #category : 'as yet unclassified' }
CanopyBranch >> mergeInto: aGlobBranch [ 
	aGlobBranch addTags: tags.
	nodes keysAndValuesDo: [ :key :value |
		aGlobBranch at: key add: self / key  ]
]

{ #category : 'enumerating' }
CanopyBranch >> recursiveDo: aBlock [ 
	aBlock value: self.
	nodes do: [ :each | 
		each recursiveDo: aBlock  ] 
	
]

{ #category : 'accessing' }
CanopyBranch >> tags: aCollection [
	nodes valuesDo: [ :each |
		each tags: aCollection ]
]
