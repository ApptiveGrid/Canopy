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
	"A branch renders as its title plus a list of links to its children (GET); a leaf renders
	its value in an editable field that PUTs the new value. PUT on a branch is not a leaf edit,
	so it delegates to the JSON handler (apply: semantics) unchanged."
	| method node |
	method := request method asUppercase.
	(method = 'GET' or: [ method = 'PUT' ]) ifFalse: [ ^ ZnResponse methodNotAllowed: request ].
	node := [ self restHandler resolveNode: request uri pathSegments ]
		on: NotFound
		do: [ :e | ^ ZnResponse notFound: request uri ].
	(node isKindOf: CanopyBranchNode) ifTrue: [
		method = 'GET' ifFalse: [ ^ self restHandler handleRequest: request ].
		^ ZnResponse ok: (ZnEntity with: (self branchPageFor: node path: request uri path) type: ZnMimeType textHtml) ].
	method = 'PUT' ifTrue: [
		| writeResponse |
		writeResponse := self restHandler handlePut: request.
		writeResponse isSuccess ifFalse: [ ^ writeResponse ].
		node := self restHandler resolveNode: request uri pathSegments ].
	^ ZnResponse ok: (ZnEntity with: (self pageFor: node path: request uri path) type: ZnMimeType textHtml)
]

{ #category : 'private' }
CanopyBrowseHtmlHandler >> branchPageFor: node path: pathString [
	"Title (the current path) plus a table with one row per child. A branch child is a link to
	drill in; a leaf child gets its value in an editable input next to its name, with a Save
	button that PUTs to the child's absolute URL. Child URLs are absolute (rooted at /) so they
	resolve regardless of a trailing slash on the request URI."
	^ String streamContents: [ :s |
		s nextPutAll: '<!DOCTYPE html><html><body>'.
		s nextPutAll: '<h1>/'; nextPutAll: (self htmlEscape: pathString); nextPutAll: '</h1>'.
		s nextPutAll: '<table>'.
		node keysAndValuesDo: [ :key :child |
			| href |
			href := self childHref: pathString key: key.
			s nextPutAll: '<tr>'.
			(child isKindOf: CanopyBranchNode)
				ifTrue: [
					s nextPutAll: '<td><a href="'; nextPutAll: (self htmlEscape: href); nextPutAll: '">';
						nextPutAll: (self htmlEscape: key asString); nextPutAll: '</a></td><td></td>' ]
				ifFalse: [
					s nextPutAll: '<td>'; nextPutAll: (self htmlEscape: key asString); nextPutAll: '</td>'.
					s nextPutAll: '<td><input value="'; nextPutAll: (self htmlEscape: (CanopyJsonVisitor new format: child));
						nextPutAll: '"><button data-href="'; nextPutAll: (self htmlEscape: href); nextPutAll: '">Save</button></td>' ].
			s nextPutAll: '</tr>' ].
		s nextPutAll: '</table>'.
		s nextPutAll: '<script>document.querySelectorAll("button[data-href]").forEach(function(b){b.addEventListener("click",function(){fetch(b.getAttribute("data-href"),{method:"PUT",body:b.previousElementSibling.value}).then(function(){location.reload();});});});</script>'.
		s nextPutAll: '</body></html>' ]
]

{ #category : 'private' }
CanopyBrowseHtmlHandler >> childHref: pathString key: key [
	"Absolute path to a child: /<currentPath>/<key>, tolerant of a leading or trailing slash
	on pathString and of an empty pathString (the root)."
	| trimmed |
	trimmed := pathString.
	(trimmed beginsWith: '/') ifTrue: [ trimmed := trimmed allButFirst ].
	(trimmed endsWith: '/') ifTrue: [ trimmed := trimmed allButLast ].
	^ trimmed isEmpty
		ifTrue: [ '/' , key asString ]
		ifFalse: [ '/' , trimmed , '/' , key asString ]
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
