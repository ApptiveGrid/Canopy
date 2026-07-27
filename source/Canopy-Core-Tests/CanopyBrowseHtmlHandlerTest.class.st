Class {
	#name : 'CanopyBrowseHtmlHandlerTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'running' }
CanopyBrowseHtmlHandlerTest >> registerBrowseTestDomain [
	| branch sub |
	branch := CanopyBranchNode new.
	branch at: #a put: (CanopyCell new value: 'x').
	sub := CanopyBranchNode new.
	sub at: #b put: (CanopyCell new value: 99).
	branch at: #sub put: sub.
	Canopy instance registerDomainNamed: #browseTest with: branch
]

{ #category : 'running' }
CanopyBrowseHtmlHandlerTest >> requestFor: method url: aUrl accept: anAcceptString body: aStringOrNil [
	| r |
	r := ZnRequest method: method url: aUrl.
	r headers at: 'Accept' put: anAcceptString.
	aStringOrNil ifNotNil: [ r entity: (ZnEntity with: aStringOrNil) ].
	^ r
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestDelegatesBranchToJsonEvenWhenAcceptIsHtml [
	"Browsable HTML links for branches need trailing-slash canonicalisation for correct
	relative resolution - deliberately out of scope for this first version, so branches
	always get JSON regardless of Accept."
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #GET url: 'http://localhost/browseTest/sub' accept: 'text/html' body: nil)) contentType equals: ZnMimeType applicationJson
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestDelegatesToJsonWhenAcceptIsNotHtml [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #GET url: 'http://localhost/browseTest/a' accept: 'application/json' body: nil)) entity contents equals: '"x"'
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestEscapesHtmlSpecialCharactersInValue [
	[ Canopy instance registerDomainNamed: #browseTest with: (CanopyBranchNode new at: #a put: (CanopyCell new value: 'x & <y>'); yourself).
	self assert: ((CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #GET url: 'http://localhost/browseTest/a' accept: 'text/html' body: nil)) entity contents includesSubstring: '&quot;x &amp; &lt;y&gt;&quot;')
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestRendersHtmlPageForLeafWhenAcceptIsHtml [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #GET url: 'http://localhost/browseTest/a' accept: 'text/html' body: nil)) entity contents
		equals: '<!DOCTYPE html><html><body><h1>/browseTest/a</h1><p>Value: <code>&quot;x&quot;</code></p><form id="f"><input id="v" value="&quot;x&quot;"><button type="submit">Save</button></form><script>document.getElementById("f").addEventListener("submit",function(e){e.preventDefault();fetch(window.location.pathname,{method:"PUT",body:document.getElementById("v").value}).then(function(){location.reload();});});</script></body></html>'
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestReturnsMethodNotAllowedForDeleteWithHtmlAccept [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #DELETE url: 'http://localhost/browseTest/a' accept: 'text/html' body: nil)) code equals: 405
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestReturnsNotFoundForUnknownPathWithHtmlAccept [
	self assert: (CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #GET url: 'http://localhost/doesNotExist' accept: 'text/html' body: nil)) code equals: 404
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestUsesInjectedRestHandler [
	| customRoot htmlHandler restHandler |
	customRoot := CanopyBranchNode new.
	customRoot at: #onlyHere put: (CanopyCell new value: 'found').
	restHandler := CanopyBrowseHandler new root: customRoot.
	htmlHandler := CanopyBrowseHtmlHandler new restHandler: restHandler.
	self assert: ((htmlHandler handleRequest: (self requestFor: #GET url: 'http://localhost/onlyHere' accept: 'text/html' body: nil)) entity contents includesSubstring: 'found')
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestWritesValueViaPutAndRendersUpdatedHtml [
	[ self registerBrowseTestDomain.
	self assert: ((CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #PUT url: 'http://localhost/browseTest/a' accept: 'text/html' body: '''z''')) entity contents includesSubstring: '&quot;z&quot;')
	] ensure: [ Canopy reset ]
]
