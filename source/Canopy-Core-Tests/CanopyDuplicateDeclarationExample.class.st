Class {
	#name : 'CanopyDuplicateDeclarationExample',
	#superclass : 'Object',
	#instVars : [
		'limit'
	],
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'canopy' }
CanopyDuplicateDeclarationExample >> limitCanopy: anInteger [
	"Deliberately wrong: two declarations writing the same key. Building a mapping from this
	object has to fail rather than let one of the two win by accident."
	<canopyValue: #limit>
	limit := anInteger
]

{ #category : 'canopy' }
CanopyDuplicateDeclarationExample >> limitTwiceCanopy: anInteger [
	<canopyValue: #limit>
	limit := anInteger
]
