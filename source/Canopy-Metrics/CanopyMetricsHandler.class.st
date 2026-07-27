Class {
	#name : 'CanopyMetricsHandler',
	#superclass : 'Object',
	#instVars : [
		'exports'
	],
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'configuring' }
CanopyMetricsHandler >> addDomain: aSymbol [
	"Export the domain aSymbol (resolved fresh per request via Canopy /) without a prefix.
	Configuring any domain switches this handler out of the default all-domains mode."
	exports add: aSymbol -> nil
]

{ #category : 'configuring' }
CanopyMetricsHandler >> addDomain: aSymbol prefix: aString [
	"Export the domain aSymbol, prefixing every metric name with aString (e.g. prefix: 'pharo'
	yields pharo_virtualMachine_memorySize). See CanopyPrometheusVisitor>>addDomain:prefix:."
	exports add: aSymbol -> aString
]

{ #category : 'accessing' }
CanopyMetricsHandler >> formatter [
	^ CanopyPrometheusVisitor new
]

{ #category : 'public' }
CanopyMetricsHandler >> handleRequest: request [
	^ ZnResponse ok: (ZnEntity
		with: self prometheusText
		type: ZnMimeType textPlain setCharSetUTF8)
]

{ #category : 'initialization' }
CanopyMetricsHandler >> initialize [
	super initialize.
	exports := OrderedCollection new.
]

{ #category : 'public' }
CanopyMetricsHandler >> prometheusText [
	"With no configured domains, export the whole Canopy tree (all domains, unprefixed) - the
	default. With domains configured, export only those, each with its optional prefix, resolving
	each domain fresh so metric values stay live and re-registration is picked up."
	| visitor |
	exports isEmpty ifTrue: [ ^ self formatter format: Canopy instance ].
	visitor := self formatter.
	exports do: [ :assoc |
		assoc value
			ifNil: [ visitor addDomain: (Canopy / assoc key) ]
			ifNotNil: [ visitor addDomain: (Canopy / assoc key) prefix: assoc value ] ].
	^ visitor export
]
