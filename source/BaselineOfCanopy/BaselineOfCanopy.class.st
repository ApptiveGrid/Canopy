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
				package: 'GlobalTree-Core';
				package: 'GlobalTree-Core-Tests' with: [ spec requires: #('GlobalTree-Core') ] ]
]
