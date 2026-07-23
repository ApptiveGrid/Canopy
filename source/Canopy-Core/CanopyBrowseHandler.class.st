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
CanopyBrowseHandler >> handleRequest: request [
	| node |
	request method asUppercase = 'GET' ifFalse: [ ^ ZnResponse methodNotAllowed: request ].
	node := self root.
	[ request uri pathSegments do: [ :segment |
		(node isKindOf: CanopyBranchNode) ifFalse: [ ^ self notFoundResponse: request ].
		node := node / segment asSymbol ] ]
		on: NotFound
		do: [ :e | ^ self notFoundResponse: request ].
	^ ZnResponse ok: (ZnEntity with: (CanopyJsonVisitor new format: node) type: ZnMimeType applicationJson)
]

{ #category : 'private' }
CanopyBrowseHandler >> notFoundResponse: request [
	^ ZnResponse notFound: request uri
]

{ #category : 'accessing' }
CanopyBrowseHandler >> root [
	^ root ifNil: [ Canopy instance ]
]

{ #category : 'accessing' }
CanopyBrowseHandler >> root: aCanopyBranchNode [
	root := aCanopyBranchNode
]
