Class {
	#name : 'CanopyZincCounterTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> testAnExcludedPrefixIsNotCounted [
	"The scrape endpoint is the obvious one to leave out: a counter of HTTP requests that counts
	the requests reading it measures partly itself."
	| counter |
	counter := CanopyZincCounter new.
	counter addExcludePrefix: '/metrics'.
	counter handleAnnouncement: (CanopyZincTestAnnouncement new url: '/metrics'; responseCode: 200 duration: 5; yourself).
	self assert: counter requests equals: 0.
	counter handleAnnouncement: (CanopyZincTestAnnouncement new url: '/api/grids'; responseCode: 200 duration: 5; yourself).
	self assert: counter requests equals: 1
]

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> testOnlyRequestsUnderAnIncludedPrefixAreCounted [
	"What the deployed servers do: narrow the count to '/api'. Without it Canopy counted every
	request the image ever answered, which is not the number the dashboards have been showing."
	| counter |
	counter := CanopyZincCounter new.
	counter addIncludePrefix: '/api'.
	counter handleAnnouncement: (CanopyZincTestAnnouncement new url: '/status'; responseCode: 200 duration: 5; yourself).
	self assert: counter requests equals: 0.
	self assert: (counter responses at: 200) equals: 0.
	counter handleAnnouncement: (CanopyZincTestAnnouncement new url: '/api/grids'; responseCode: 200 duration: 5; yourself).
	self assert: counter requests equals: 1.
	self assert: (counter responses at: 200) equals: 1
]

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> testAFreshCounterAlreadyCarriesTheUsualStatusCodes [
	"Parity with what the servers export today: the status series exist from the first scrape at
	zero instead of appearing with the first response of that kind, and the average duration is a
	number rather than nil - which is not even valid exposition."
	| counter |
	counter := CanopyZincCounter new.
	self assert: counter duration equals: 0.
	self assert: (counter responses at: 200) equals: 0.
	self assert: (counter responses at: 500) equals: 0.
	self assert: counter responses size equals: 15
]

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> testHandleAnnouncementFoldsDurationsIntoARunningAverage [
	"Mirrors ZincCounter (pharo-metrics): the average starts at zero and every duration is folded
	in with 99% weight on the running value. The first request therefore does not set a baseline -
	it moves the average by a hundredth, which is what the servers have been exporting all along.
	Canopy did set the baseline from the first request, because its average started as nil; the
	nil guard in adjustDuration: is unreachable now."
	[ CanopyZincCounter reset.
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 200 duration: 1000; yourself).
	self assert: CanopyZincCounter instance duration equals: 10.
	CanopyZincCounter instance handleAnnouncement: (CanopyZincTestAnnouncement new responseCode: 200 duration: 1000; yourself).
	self assert: CanopyZincCounter instance duration equals: (((99 * 10) + 1000) / 100) asInteger ]
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
	self assert: (output includesSubstring: 'zinc_httpRequests 2 ').
	self assert: (output includesSubstring: 'zinc_httpResponses{status="200"} 1 ').
	self assert: (output includesSubstring: 'zinc_httpResponses{status="404"} 1 ').
	self assert: (output includesSubstring: '# HELP zinc_duration Average duration of requests') ]
		ensure: [ CanopyZincCounter instance uninstall. Canopy reset. CanopyZincCounter reset ]
]

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> announcerSubscriptionsOfTheCounter [
	"The one place this test reaches into the announcer. What it is really asking is how often
	the counter is subscribed, and the announcer is the only one who knows."
	^ ZnLogEvent announcer subscriptions subscriptions
		select: [ :each | each subscriber == CanopyZincCounter instance ]
]

{ #category : 'as yet unclassified' }
CanopyZincCounterTest >> testRegisterZincMetricsTwiceSubscribesOnce [
	"Both halves of a second registration used to go wrong, and only one of them said so: the
	domain registration raised, and before it did, the counter had already subscribed a second
	time - so a retry, or a caller that swallowed the error, counted every request twice from
	then on."
	[ CanopyZincCounter reset.
	Canopy registerZincMetrics.
	self shouldnt: [ Canopy registerZincMetrics ] raise: Error.
	self assert: self announcerSubscriptionsOfTheCounter size equals: 1.
	self assert: Canopy domainNames asArray equals: #( #zinc ) ]
		ensure: [ CanopyZincCounter instance uninstall. Canopy reset. CanopyZincCounter reset ]
]
