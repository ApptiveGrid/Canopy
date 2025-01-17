Class {
	#name : 'GlobalTreeObjectConfigurator',
	#superclass : 'Object',
	#classInstVars : [
		'instance'
	],
	#category : 'GlobalTree-Core',
	#package : 'GlobalTree-Core'
}

{ #category : 'accessing' }
GlobalTreeObjectConfigurator class >> instance [
	^ instance ifNil: [ 
		instance := self new  ]
]

{ #category : 'as yet unclassified' }
GlobalTreeObjectConfigurator class >> setup: anObject [ 
	^ self instance setup: anObject
]

{ #category : 'as yet unclassified' }
GlobalTreeObjectConfigurator >> globalTreeMapFor: anObject [  
	| pragmas map |
	map := GlobalTreeMap new.
	map add: anObject.
	^ map

]

{ #category : 'as yet unclassified' }
GlobalTreeObjectConfigurator >> setup: anObject [ 
	^ self globalTreeMapFor: anObject .

]
