Class {
	#name : 'CanopyMetricsHandler',
	#superclass : 'Object',
	#category : 'Canopy-Metrics',
	#package : 'Canopy-Metrics'
}

{ #category : 'accessing' }
CanopyMetricsHandler >> formatter [
	^ CanopyPrometheusVisitor new
]

{ #category : 'public' }
CanopyMetricsHandler >> handleRequest: request [
	^ ZnResponse ok: (ZnEntity
		with: (self formatter format: Canopy instance)
		type: ZnMimeType textPlain setCharSetUTF8)
]
