Class {
	#name : 'CanopyBrowseHandler',
	#superclass : 'Object',
	#instVars : [
		'root'
	],
	#category : 'Canopy-Core',
	#package : 'Canopy-Core'
}

{ #category : 'public' }
CanopyBrowseHandler >> handleGet: request [
	| node |
	node := [ self resolveNode: request uri pathSegments ]
		on: NotFound
		do: [ :e | ^ self notFoundResponse: request ].
	^ self jsonResponse: node
]

{ #category : 'public' }
CanopyBrowseHandler >> handlePut: request [
	| node payload |
	node := [ self resolveNode: request uri pathSegments ]
		on: NotFound
		do: [ :e | ^ self notFoundResponse: request ].
	payload := self parsePayload: request.
	(payload isKindOf: CanopyBranchNode)
		ifTrue: [
			(node isKindOf: CanopyBranchNode) ifFalse: [ ^ ZnResponse badRequest: request ].
			node apply: payload ]
		ifFalse: [
			(node isKindOf: CanopyBranchNode) ifTrue: [ ^ ZnResponse badRequest: request ].
			node value: payload value ].
	^ self jsonResponse: node
]

{ #category : 'public' }
CanopyBrowseHandler >> handleRequest: request [
	| method |
	method := request method asUppercase.
	method = 'GET' ifTrue: [ ^ self handleGet: request ].
	method = 'PUT' ifTrue: [ ^ self handlePut: request ].
	^ ZnResponse methodNotAllowed: request
]

{ #category : 'private' }
CanopyBrowseHandler >> jsonResponse: node [
	^ ZnResponse ok: (ZnEntity with: (CanopyJsonVisitor new format: node) type: ZnMimeType applicationJson)
]

{ #category : 'private' }
CanopyBrowseHandler >> notFoundResponse: request [
	^ ZnResponse notFound: request uri
]

{ #category : 'private' }
CanopyBrowseHandler >> parsePayload: request [
	^ request entity contents asCanopy
]

{ #category : 'private' }
CanopyBrowseHandler >> resolveNode: pathSegments [
	| node |
	node := self root.
	pathSegments do: [ :segment |
		(node isKindOf: CanopyBranchNode) ifFalse: [ NotFound signalFor: segment in: node ].
		node := node / segment asSymbol ].
	^ node
]

{ #category : 'accessing' }
CanopyBrowseHandler >> root [
	^ root ifNil: [ Canopy instance ]
]

{ #category : 'accessing' }
CanopyBrowseHandler >> root: aCanopyBranchNode [
	root := aCanopyBranchNode
]
