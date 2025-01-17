Class {
	#name : 'GlobBranch',
	#superclass : 'GlobNode',
	#instVars : [
		'nodes'
	],
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'arithmetic' }
GlobBranch >> / aString [ 
	^ self at: aString 
]

{ #category : 'arithmetic' }
GlobBranch >> /+ aString [ 
	^ self ensureAt: aString 
]

{ #category : 'composition' }
GlobBranch >> @ aSymbol [
	^ (self at: aSymbol) value  
]

{ #category : 'accessing' }
GlobBranch >> at: key [ 
	^ nodes 
		at: key 
		ifAbsent: [ NotFound signal: 'cannot find key ', key asString , ' in ', self printString ]
]

{ #category : 'accessing' }
GlobBranch >> at: aString add: aGlobBranch [ 
	nodes  
		at: aString 
		ifPresent: [ :value | value merge: aGlobBranch ]
		ifAbsent: [ self at: aString put: aGlobBranch ]
]

{ #category : 'accessing' }
GlobBranch >> at: aString ifAbsent: aBlock [ 
	^ nodes 
		at: aString 
		ifAbsent: aBlock 
]

{ #category : 'accessing' }
GlobBranch >> at: key put: value [ 
	(value isKindOf: GlobNode) ifTrue: [  
		value parent: self ].
	nodes at: key put: value.
	^ value 
]

{ #category : 'accessing' }
GlobBranch >> ensureAt: key [ 
	^ nodes 
		at: key 
		ifAbsent: [ 
			self at: key put: GlobBranch new ]
]

{ #category : 'as yet unclassified' }
GlobBranch >> importTree: anObject [ 
	self 
		importTree: anObject tags: #()
]

{ #category : 'as yet unclassified' }
GlobBranch >> importTree: anObject tags: aCollection [
	| tree |
	tree := anObject asGlobalTree.
	tree recursiveDo: [ :each | each addTags: aCollection ].
	self merge: tree.
	"tree keys do: [ :key | 
		self at: key put: (tree at: key) ].
	tree addTags: aCollection."
	^ tree
]

{ #category : 'initialization' }
GlobBranch >> initialize [ 
	super initialize.
	nodes := Dictionary new 
]

{ #category : 'inspector' }
GlobBranch >> inspectionEntries [
	<inspectorPresentationOrder: 0 title: 'global branch'>

	^ SpTablePresenter new
		items: nodes values;
		addColumn: (SpStringTableColumn new
			title: 'key'";
			width: 30";
			evaluated: [:each | each inspectionLabel  ])
]

{ #category : 'accessing' }
GlobBranch >> inspectionLabel [
	^ self key 
]

{ #category : 'as yet unclassified' }
GlobBranch >> keyOf: aGlobBranch [ 
	^ nodes keyAtValue: aGlobBranch 
]

{ #category : 'accessing' }
GlobBranch >> keys [
	^ nodes keys 
]

{ #category : 'enumerating' }
GlobBranch >> keysAndValuesDo: aBlock [ 
	^ nodes keysAndValuesDo: aBlock 
]

{ #category : 'as yet unclassified' }
GlobBranch >> mergeInto: aGlobBranch [ 
	aGlobBranch addTags: tags.
	nodes keysAndValuesDo: [ :key :value |
		aGlobBranch at: key add: self / key  ]
]

{ #category : 'enumerating' }
GlobBranch >> recursiveDo: aBlock [ 
	aBlock value: self.
	nodes do: [ :each | 
		each recursiveDo: aBlock  ] 
	
]

{ #category : 'accessing' }
GlobBranch >> tags: aCollection [
	nodes valuesDo: [ :each |
		each tags: aCollection ]
]
