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

{ #category : 'instance creation' }
CanopyMappingBuilder class >> build: anObject [ 
	^ self new build: anObject
]

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
		allNamed: #canopyMapping
		from: object class 
		to: Object.
	(pragmas size = 1) ifTrue: [ 
		object 
			perform: pragmas first selector asMutator 
			with: self ]
]

{ #category : 'as yet unclassified' }
CanopyMappingBuilder >> buildLocalProperties [
	| pragmas |
	pragmas := Pragma 
		allNamed: #canopyValue:type:arguments:
		from: object class 
		to: Object.
	(pragmas size > 0) ifTrue: [ 
		pragmas do: [ :pragma | 
			map 
				at: (pragma arguments first)
				put: ((CanopyLeafNode withType: pragma arguments second) new 
					object: object;
					initializeFromPragma: pragma) ] ].
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
