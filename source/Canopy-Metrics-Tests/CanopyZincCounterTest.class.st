Class {
	#name : 'CanopyZincCounterTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> testHandleAnnouncementAdjustsDurationWithExponentialMovingAverage [
	"Mirrors ZincCounter (pharo-metrics, out of scope otherwise): first duration sets the
	baseline, subsequent durations are folded in with 99% weight on the running average."
	[ CanopyZincCounter reset.
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 200 duration: 10; yourself).
	self assert: CanopyZincCounter instance duration equals: 10.
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 200 duration: 20; yourself).
	self assert: CanopyZincCounter instance duration equals: (((99 * 10) + 20) / 100) asInteger ]
		ensure: [ CanopyZincCounter reset ]
]

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> testHandleAnnouncementIncrementsRequestsAndStatusCounts [
	[ CanopyZincCounter reset.
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 200 duration: 10; yourself).
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 200 duration: 10; yourself).
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 404 duration: 10; yourself).
	self assert: CanopyZincCounter instance requests equals: 3.
	self assert: (CanopyZincCounter instance responses at: 200) equals: 2.
	self assert: (CanopyZincCounter instance responses at: 404) equals: 1 ]
		ensure: [ CanopyZincCounter reset ]
]

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> testRegisterZincMetricsRegistersZincDomainWithExpectedValues [
	"End-to-end: registerZincMetrics installs CanopyZincCounter (subscribes to live Zinc
	server traffic - independent of pharo-metrics, per Norbert 2026-07-21) and registers
	#zinc as a Canopy domain. Values fed in directly rather than via a real HTTP request."
	| output |
	[ CanopyZincCounter reset.
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 200 duration: 10; yourself).
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 404 duration: 20; yourself).
	Canopy registerZincMetrics.
	output := CanopyPrometheusVisitor new format: Canopy instance.
	self assert: (output includesSubstring: 'zinc_httpRequests{} 2 ').
	self assert: (output includesSubstring: 'zinc_httpResponses{status="200"} 1 ').
	self assert: (output includesSubstring: 'zinc_httpResponses{status="404"} 1 ').
	self assert: (output includesSubstring: '# HELP zinc_duration Average duration of requests') ]
		ensure: [ CanopyZincCounter instance uninstall. Canopy reset. CanopyZincCounter reset ]
]
