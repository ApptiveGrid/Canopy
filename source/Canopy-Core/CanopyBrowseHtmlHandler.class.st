Class {
	#name : 'CanopyBrowseHtmlHandler',
	#superclass : 'Object',
	#instVars : [
		'restHandler'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'public' }
CanopyBrowseHtmlHandler >> handleRequest: request [
	(self wantsHtml: request) ifFalse: [ ^ self restHandler handleRequest: request ].
	^ self handleHtmlRequest: request
]

{ #category : 'private' }
CanopyBrowseHtmlHandler >> handleHtmlRequest: request [
	"HTML is only rendered for leaf values (the concrete ask: show a value, edit it via PUT).
	Branches still get JSON regardless of Accept - browsable HTML links for branches need
	trailing-slash canonicalization for correct relative resolution, deliberately out of scope
	for this first version."
	| method node |
	method := request method asUppercase.
	(method = 'GET' or: [ method = 'PUT' ]) ifFalse: [ ^ ZnResponse methodNotAllowed: request ].
	node := [ self restHandler resolveNode: request uri pathSegments ]
		on: NotFound
		do: [ :e | ^ ZnResponse notFound: request uri ].
	(node isKindOf: CanopyBranchNode) ifTrue: [ ^ self restHandler handleRequest: request ].
	method = 'PUT' ifTrue: [
		| writeResponse |
		writeResponse := self restHandler handlePut: request.
		writeResponse isSuccess ifFalse: [ ^ writeResponse ].
		node := self restHandler resolveNode: request uri pathSegments ].
	^ ZnResponse ok: (ZnEntity with: (self pageFor: node path: request uri path) type: ZnMimeType textHtml)
]

{ #category : 'private' }
CanopyBrowseHtmlHandler >> htmlEscape: aString [
	| out |
	out := WriteStream on: String new.
	aString do: [ :ch |
		ch = $& ifTrue: [ out nextPutAll: '&amp;' ]
		ifFalse: [ ch = $< ifTrue: [ out nextPutAll: '&lt;' ]
		ifFalse: [ ch = $> ifTrue: [ out nextPutAll: '&gt;' ]
		ifFalse: [ ch = $" ifTrue: [ out nextPutAll: '&quot;' ]
		ifFalse: [ out nextPut: ch ] ] ] ] ].
	^ out contents
]

{ #category : 'private' }
CanopyBrowseHtmlHandler >> pageFor: node path: pathString [
	| currentJson |
	currentJson := CanopyJsonVisitor new format: node.
	^ String streamContents: [ :s |
		s nextPutAll: '<!DOCTYPE html><html><body>'.
		s nextPutAll: '<h1>/'; nextPutAll: (self htmlEscape: pathString); nextPutAll: '</h1>'.
		s nextPutAll: '<p>Value: <code>'; nextPutAll: (self htmlEscape: currentJson); nextPutAll: '</code></p>'.
		s nextPutAll: '<form id="f"><input id="v" value="'; nextPutAll: (self htmlEscape: currentJson); nextPutAll: '"><button type="submit">Save</button></form>'.
		s nextPutAll: '<script>document.getElementById("f").addEventListener("submit",function(e){e.preventDefault();fetch(window.location.pathname,{method:"PUT",body:document.getElementById("v").value}).then(function(){location.reload();});});</script>'.
		s nextPutAll: '</body></html>' ]
]

{ #category : 'accessing' }
CanopyBrowseHtmlHandler >> restHandler [
	^ restHandler ifNil: [ restHandler := CanopyBrowseHandler new ]
]

{ #category : 'accessing' }
CanopyBrowseHtmlHandler >> restHandler: aCanopyBrowseHandler [
	restHandler := aCanopyBrowseHandler
]

{ #category : 'private' }
CanopyBrowseHtmlHandler >> wantsHtml: request [
	^ request accept notNil and: [ request accept includesSubstring: 'text/html' ]
]
