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
	"An object may land on a leaf as well as on a branch: the leaf takes it as a single value,
	the same way a configuration file hands a subtree to a component's write method. Only a
	scalar on a branch has nowhere to go."
	(payload isKindOf: CanopyBranchNode)
		ifTrue: [ node apply: payload ]
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
	^ ZnResponse ok: (ZnEntity with: (STON toJsonString: node asRawValue) type: ZnMimeType applicationJson)
]

{ #category : 'private' }
CanopyBrowseHandler >> notFoundResponse: request [
	^ ZnResponse notFound: request uri
]

{ #category : 'private' }
CanopyBrowseHandler >> parsePayload: request [
	^ request entity contents asCanopy
]

{ #category : 'accessing' }
CanopyBrowseHandler >> resolveNode: pathSegments [
	"Not private: CanopyBrowseHtmlHandler reuses this to resolve the target node itself,
	rather than duplicating navigation or depending on the JSON response shape."
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
