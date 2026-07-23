Class {
	#name : 'CanopyComposedAppExample',
	#superclass : 'Object',
	#instVars : [
		'componentA',
		'componentB'
	],
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'as yet unclassified' }
CanopyComposedAppExample >> canopyBranch: aBuilder [
	<canopyBranch>
	aBuilder at: #componentA addMapping: componentA.
	aBuilder at: #componentB addMapping: componentB
]

{ #category : 'accessing' }
CanopyComposedAppExample >> componentA [
	^ componentA
]

{ #category : 'accessing' }
CanopyComposedAppExample >> componentB [
	^ componentB
]

{ #category : 'initialization' }
CanopyComposedAppExample >> initialize [
	super initialize.
	componentA := CanopyComposedSubComponent new.
	componentB := CanopyComposedSubComponent new
]
