Extension { #name : 'CanopyBranchNode' }

{ #category : '*Canopy-Metrics' }
CanopyBranchNode >> counter: aKey description: aString reading: aBlock [
	"A counter under aKey, read by evaluating aBlock at every scrape. See
	#metric:at:reading:"
	^ self
		metric: (CanopyMetric new
			type: #counter;
			description: aString;
			yourself)
		at: aKey
		reading: aBlock
]

{ #category : '*Canopy-Metrics' }
CanopyBranchNode >> gauge: aKey description: aString reading: aBlock [
	"A gauge under aKey, read by evaluating aBlock at every scrape. See
	#metric:at:reading:"
	^ self
		metric: (CanopyMetric new
			type: #gauge;
			description: aString;
			yourself)
		at: aKey
		reading: aBlock
]

{ #category : '*Canopy-Metrics' }
CanopyBranchNode >> gauge: aKey label: aSymbol description: aString reading: aBlock [
	"A gauge with one line per key of the dictionary aBlock answers, the key written under
	the label aSymbol. See #metric:at:reading:"
	^ self
		metric: (CanopyMetricMap new
			type: #gauge;
			description: aString;
			labelName: aSymbol;
			yourself)
		at: aKey
		reading: aBlock
]

{ #category : '*Canopy-Metrics' }
CanopyBranchNode >> metric: aMetric at: aKey reading: aBlock [
	"The one shape every runtime metric of the servers had been spelled out in by hand: an
	accessor whose block builds the metric and reads its value. Here it is said once, and a
	server says only what is its own - the name, what it means, and where the number comes
	from.

	The metric is copied for every read rather than filled in place: two scrapes at once would
	otherwise write into the same holder. A block that answers nil leaves the leaf out of the
	scrape - see CanopyMetric>>readingsDo: - and one that raises costs this leaf and not the
	scrape, see CanopyPrometheusVisitor>>visitMetric:.

	Declaring the same key again replaces the leaf, so a server that is set up twice does not
	have to know it was set up before."
	^ self
		at: aKey
		put: (CanopyAccessor reading: [
			aMetric copy
				value: aBlock value;
				yourself ])
]
