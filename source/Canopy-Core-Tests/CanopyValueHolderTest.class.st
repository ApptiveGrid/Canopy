Class {
	#name : 'CanopyValueHolderTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyValueHolderTest >> testRawObjectIsWrappedIntoAPlainValue [
	"Anything that is not already a holder becomes a CanopyValue carrying nothing but itself."
	| holder |
	holder := 42 asCanopyValue.
	self assert: holder class equals: CanopyValue.
	self assert: holder value equals: 42
]

{ #category : 'as yet unclassified' }
CanopyValueHolderTest >> testWrappingAHolderIsTheIdentity [
	"asCanopyValue is idempotent, and that is what lets a pragma method return either a raw
	value or a holder without Canopy having to ask which of the two it got."
	| holder |
	holder := 42 asCanopyValue.
	self assert: holder asCanopyValue identicalTo: holder
]
