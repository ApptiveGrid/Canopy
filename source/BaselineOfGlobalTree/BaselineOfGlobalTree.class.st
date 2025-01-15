Class {
	#name : 'BaselineOfGlobalTree',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGlobalTree',
	#package : 'BaselineOfGlobalTree'
}

{ #category : 'baselines' }
BaselineOfGlobalTree >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				package: 'GlobalTree-Core';
				package: 'GlobalTree-Core-Tests' with: [ spec requires: #('GlobalTree-Core') ] ]
]
