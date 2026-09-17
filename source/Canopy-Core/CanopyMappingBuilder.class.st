Class {
	#name : 'CanopyMappingBuilder',
	#superclass : 'Object',
	#instVars : [
		'object',
		'map'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'adding' }
CanopyMappingBuilder >> addMapping: anObject [
	self class new 
		object: anObject;
		map: map;
		build
]

{ #category : 'accessing' }
CanopyMappingBuilder >> at: aString addMapping: anObject [
	| value |
	value := self class new
		object: anObject;
		map: CanopyBranchNode new;
		build.
	
	(map /+ aString) merge: value 
]

{ #category : 'instance creation' }
CanopyMappingBuilder >> build [
	self buildLocalProperties.
	self buildComplexProperties.
	
	^ map 
]

{ #category : 'as yet unclassified' }
CanopyMappingBuilder >> buildComplexProperties [
	| pragmas |
	pragmas := Pragma
		allNamed: #canopyBranch
		from: object class
		to: Object.
	(pragmas size = 1) ifTrue: [
		object
			perform: pragmas first selector asMutator
			with: self ]
]

{ #category : 'as yet unclassified' }
CanopyMappingBuilder >> buildLocalProperties [
	"One leaf per key, however many declarations point at it: a getter and a setter for the same
	key are two pragmas and one node, which is the only way a value can be read and written at
	the same place. Two declarations in the same direction are a mistake and say so out loud -
	they used to silently overwrite each other, depending on the order the pragmas came in."
	| leaves |
	leaves := Dictionary new.
	self canopyPragmas do: [ :pragma |
		(leaves
			at: pragma arguments first
			ifAbsentPut: [ CanopyAccessor new object: object ])
				initializeFromPragma: pragma ].
	leaves keysAndValuesDo: [ :key :leaf |
		map at: key put: leaf ]
]

{ #category : 'as yet unclassified' }
CanopyMappingBuilder >> canopyPragmas [
	"Both forms of the declaration: the marker that carries nothing but the key, and the older
	one that also carried a type and arguments. The old form stays readable, so the declarations
	in the pinned downstream repos keep working while they are moved over."
	^ (Pragma allNamed: #canopyValue: from: object class to: Object)
		, (Pragma allNamed: #canopyValue:type:arguments: from: object class to: Object)
]

{ #category : 'initialization' }
CanopyMappingBuilder >> initialize [ 
	super initialize.
	map := CanopyBranchNode new.
]

{ #category : 'accessing' }
CanopyMappingBuilder >> map [

	^ map ifNil: [ 
		map := Dictionary new ]
]

{ #category : 'accessing' }
CanopyMappingBuilder >> map: anObject [

	map := anObject
]

{ #category : 'accessing' }
CanopyMappingBuilder >> object [

	^ object
]

{ #category : 'accessing' }
CanopyMappingBuilder >> object: anObject [

	object := anObject
]
