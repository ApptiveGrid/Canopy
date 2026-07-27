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
CanopyBrowseHtmlHandlerTest >> testHandleRequestRendersHtmlListForBranchWhenAcceptIsHtml [
	"A branch now renders as an HTML page: its path as title plus one link per child node
	(absolute hrefs). Order is dictionary-defined, so assert per child, not the whole string."
	| body response |
	[ self registerBrowseTestDomain.
	response := CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #GET url: 'http://localhost/browseTest' accept: 'text/html' body: nil).
	self assert: response contentType equals: ZnMimeType textHtml.
	body := response entity contents.
	self assert: (body includesSubstring: '<h1>/browseTest</h1>').
	self assert: (body includesSubstring: '<li><a href="/browseTest/a">a</a></li>').
	self assert: (body includesSubstring: '<li><a href="/browseTest/sub">sub</a></li>')
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestRendersNestedBranchChildLinksAbsolutely [
	"Child links of a nested branch keep the full path from root, so following them lands on
	the child, not a sibling - the trailing-slash resolution issue that had this deferred."
	[ self registerBrowseTestDomain.
	self assert: ((CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #GET url: 'http://localhost/browseTest/sub' accept: 'text/html' body: nil)) entity contents includesSubstring: '<li><a href="/browseTest/sub/b">b</a></li>')
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHtmlHandlerTest >> testHandleRequestDelegatesBranchToJsonWhenAcceptIsNotHtml [
	"Without text/html in Accept, a branch still gets plain JSON (the decorator only adds HTML)."
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHtmlHandler new handleRequest: (self requestFor: #GET url: 'http://localhost/browseTest/sub' accept: 'application/json' body: nil)) contentType equals: ZnMimeType applicationJson
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
