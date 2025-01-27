Class {
	#name : 'BaselineOfCanopy',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCanopy',
	#package : 'BaselineOfCanopy'
}

{ #category : 'baselines' }
BaselineOfCanopy >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				package: 'Canopy-Core';
				package: 'Canopy-Core-Tests' with: [ spec requires: #('Canopy-Core') ] ]
]
