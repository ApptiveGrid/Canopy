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
CanopyMappingBuilder >> add: anObject [
	self class new 
		object: anObject;
		map: map;
		build
]

{ #category : 'accessing' }
CanopyMappingBuilder >> at: aString putNested: anObject [
	| value |
	value := self class new
		object: anObject;
		map: CanopyBranch new;
		build.
	
	map 
		at: aString 
		put: value
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
		allNamed: #globalTreeMap
		from: object class 
		to: Object.
	(pragmas size = 1) ifTrue: [ 
		object perform: pragmas first selector asMutator with: self ]
]

{ #category : 'as yet unclassified' }
CanopyMappingBuilder >> buildLocalProperties [
	| pragmas |
	pragmas := Pragma 
		allNamed: #globalTreeValue:type:
		from: object class 
		to: Object.
	(pragmas size > 0) ifTrue: [ 
		pragmas do: [ :pragma | 
			map 
				at: (pragma arguments first)
				put: (CanopyAccessor new 
					object: object;
					selector: pragma method selector) ] ].
]

{ #category : 'accessing' }
CanopyMappingBuilder >> map [

	^ map
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
