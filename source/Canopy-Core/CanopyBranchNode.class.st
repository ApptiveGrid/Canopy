Class {
	#name : 'CanopyBranchNode',
	#superclass : 'CanopyNode',
	#instVars : [
		'nodes'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'copying' }
CanopyBranchNode >> , aGlobBranch [ 
	aGlobBranch mergeInto: self 
]

{ #category : 'arithmetic' }
CanopyBranchNode >> / aString [ 
	^ self at: aString 
]

{ #category : 'arithmetic' }
CanopyBranchNode >> /+ aString [ 
	^ self ensureAt: aString 
]

{ #category : 'composition' }
CanopyBranchNode >> @ aSymbol [
	^ (self at: aSymbol) value  
]

{ #category : 'visiting' }
CanopyBranchNode >> acceptCanopy: aVisitor [ 
	aVisitor visitBranchNode: self 
]

{ #category : 'target resize' }
CanopyBranchNode >> apply: aGlobBranch [ 
	aGlobBranch keysAndValuesDo: [ :key : value |
		(value isKindOf: CanopyBranchNode)
			ifTrue: [ (nodes at: key) apply: value ]
			ifFalse: [ (nodes at: key) value: value value ]
		 ]
]

{ #category : 'accessing' }
CanopyBranchNode >> at: key [ 
	^ nodes 
		at: key 
		ifAbsent: [ NotFound signal: 'cannot find key ', key asString , ' in ', self printString ]
]

{ #category : 'accessing' }
CanopyBranchNode >> at: aString add: aGlobBranch [ 
	nodes  
		at: aString 
		ifPresent: [ :value | value merge: aGlobBranch ]
		ifAbsent: [ self at: aString put: aGlobBranch ]
]

{ #category : 'accessing' }
CanopyBranchNode >> at: aString ifAbsent: aBlock [ 
	^ nodes 
		at: aString 
		ifAbsent: aBlock 
]

{ #category : 'accessing' }
CanopyBranchNode >> at: key put: value [ 
	(value isKindOf: CanopyNode) ifTrue: [  
		value parent: self ].
	nodes at: key put: value.
	^ value 
]

{ #category : 'accessing' }
CanopyBranchNode >> ensureAt: key [ 
	^ nodes 
		at: key 
		ifAbsent: [ 
			self at: key put: CanopyBranchNode new ]
]

{ #category : 'as yet unclassified' }
CanopyBranchNode >> importTree: anObject [ 
	self 
		importTree: anObject tags: #()
]

{ #category : 'as yet unclassified' }
CanopyBranchNode >> importTree: anObject tags: aCollection [
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
CanopyBranchNode >> initialize [ 
	super initialize.
	nodes := Dictionary new 
]

{ #category : 'inspector' }
CanopyBranchNode >> inspectionEntries [
	<inspectorPresentationOrder: 0 title: 'global branch'>

	^ SpTablePresenter new
		items: nodes values;
		addColumn: (SpStringTableColumn new
			title: 'key'";
			width: 30";
			evaluated: [:each | each inspectionKey  ]);
		addColumn: (SpStringTableColumn new
			title: 'value'";
			width: 30";
			evaluated: [:each | each inspectionValue  ])
]

{ #category : 'accessing' }
CanopyBranchNode >> inspectionKey [
	^ self key 
]

{ #category : 'accessing' }
CanopyBranchNode >> inspectionValue [ 
	^ '-->'
]

{ #category : 'as yet unclassified' }
CanopyBranchNode >> keyOf: aGlobBranch [ 
	^ nodes keyAtValue: aGlobBranch 
]

{ #category : 'accessing' }
CanopyBranchNode >> keys [
	^ nodes keys 
]

{ #category : 'enumerating' }
CanopyBranchNode >> keysAndValuesDo: aBlock [ 
	^ nodes keysAndValuesDo: aBlock 
]

{ #category : 'as yet unclassified' }
CanopyBranchNode >> mergeInto: aGlobBranch [ 
	aGlobBranch addTags: tags.
	nodes keysAndValuesDo: [ :key :value |
		aGlobBranch at: key add: self / key  ]
]

{ #category : 'accessing' }
CanopyBranchNode >> nodes [
	^ nodes
]

{ #category : 'enumerating' }
CanopyBranchNode >> recursiveDo: aBlock [ 
	aBlock value: self.
	nodes do: [ :each | 
		each recursiveDo: aBlock  ] 
	
]

{ #category : 'accessing' }
CanopyBranchNode >> tags: aCollection [
	nodes valuesDo: [ :each |
		each tags: aCollection ]
]
