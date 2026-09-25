"
The runtime metrics a server declares on a branch - #gauge:description:reading: and its
siblings - and what a scrape makes of them.
"
Class {
	#name : 'CanopyDeclaredMetricTest',
	#superclass : 'TestCase',
	#instVars : [
		'root',
		'branch'
	],
	#category : 'Canopy-Metrics-Tests',
	#package : 'Canopy-Metrics-Tests'
}

{ #category : 'running' }
CanopyDeclaredMetricTest >> scrape [
	^ CanopyPrometheusVisitor new format: root
]

{ #category : 'running' }
CanopyDeclaredMetricTest >> setUp [
	super setUp.
	root := CanopyBranchNode new.
	branch := root /+ #server
]

{ #category : 'tests' }
CanopyDeclaredMetricTest >> testACounterIsWrittenAsOne [
	branch counter: #requests description: 'requests served' reading: [ 3 ].
	self assert: (self scrape includesSubstring: '# TYPE server_requests counter').
	self assert: (self scrape includesSubstring: 'server_requests 3 ')
]

{ #category : 'tests' }
CanopyDeclaredMetricTest >> testAGaugeIsReadAtEveryScrape [
	| count |
	count := 1.
	branch gauge: #open description: 'open databases' reading: [ count ].
	self assert: (self scrape includesSubstring: '# HELP server_open open databases').
	self assert: (self scrape includesSubstring: 'server_open 1 ').
	count := 2.
	self assert: (self scrape includesSubstring: 'server_open 2 ')
]

{ #category : 'tests' }
CanopyDeclaredMetricTest >> testALabelledGaugeWritesALinePerKey [
	branch
		gauge: #owing
		label: #task
		description: 'databases owing a task'
		reading: [ { #backup -> 4. #repair -> 0 } asDictionary ].
	self assert: (self scrape includesSubstring: 'server_owing{task="backup"} 4 ').
	self assert: (self scrape includesSubstring: 'server_owing{task="repair"} 0 ')
]

{ #category : 'tests' }
CanopyDeclaredMetricTest >> testAValueThatIsNotKnownIsLeftOut [
	"a gap, not a line that says nil or a zero that says something is known"
	branch gauge: #counted description: 'not counted yet' reading: [ nil ].
	branch gauge: #owing label: #task description: 'not counted yet' reading: [ nil ].
	branch gauge: #known description: 'known' reading: [ 7 ].
	self deny: (self scrape includesSubstring: 'server_counted').
	self deny: (self scrape includesSubstring: 'server_owing').
	self assert: (self scrape includesSubstring: 'server_known 7 ')
]

{ #category : 'tests' }
CanopyDeclaredMetricTest >> testDeclaringAgainReplaces [
	branch gauge: #open description: 'open databases' reading: [ 1 ].
	branch gauge: #open description: 'open databases' reading: [ 2 ].
	self deny: (self scrape includesSubstring: 'server_open 1 ').
	self assert: (self scrape includesSubstring: 'server_open 2 ')
]
