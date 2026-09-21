"
A component whose reader raises, which is what a live one does on a bad day -
the servers read their values out of blocks, and AGSoilMetrics reduces over every
open database while databases open and close underneath it.

Here to hold the exporter to its promise that such a leaf costs that leaf and not
the whole scrape.
"
Class {
	#name : 'CanopyRaisingLeafExample',
	#superclass : 'Object',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'accessing' }
CanopyRaisingLeafExample >> brokenReading [
	^ self error: 'this component cannot answer today'
]
