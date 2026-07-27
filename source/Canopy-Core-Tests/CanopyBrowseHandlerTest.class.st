Class {
	#name : 'CanopyBrowseHandlerTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

{ #category : 'running' }
CanopyBrowseHandlerTest >> putRequestFor: aUrl body: aString [
	^ (ZnRequest put: aUrl) entity: (ZnEntity with: aString); yourself
]

{ #category : 'running' }
CanopyBrowseHandlerTest >> registerBrowseTestDomain [
	| branch sub |
	branch := CanopyBranchNode new.
	branch at: #a put: (CanopyCell new value: 'x').
	sub := CanopyBranchNode new.
	sub at: #b put: (CanopyCell new value: 99).
	branch at: #sub put: sub.
	Canopy instance registerDomainNamed: #browseTest with: branch
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandlePutAppliesJsonObjectOntoExistingBranchIgnoringUnknownKeys [
	"apply: (reused as-is, same semantics already used for config hot-reload/canopySetupFrom:)
	overwrites keys that exist and silently ignores keys the target branch does not declare -
	this is intentional, not a gap: components only expose the slots they declared via pragma,
	an HTTP PUT cannot invent a new one."
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHandler new handleRequest: (self putRequestFor: 'http://localhost/browseTest/sub' body: '{"b":123,"unknown":1}')) entity contents
		equals: '{"b":123}'
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandlePutOnBranchWithScalarPayloadReturnsBadRequest [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHandler new handleRequest: (self putRequestFor: 'http://localhost/browseTest/sub' body: '42')) code equals: 400
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandlePutOnLeafWithObjectPayloadReturnsBadRequest [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHandler new handleRequest: (self putRequestFor: 'http://localhost/browseTest/a' body: '{"x":1}')) code equals: 400
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandlePutOverwritesLeafValue [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHandler new handleRequest: (self putRequestFor: 'http://localhost/browseTest/a' body: '''y''')) entity contents equals: '"y"'
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandlePutReturnsNotFoundForUnknownPath [
	self assert: (CanopyBrowseHandler new handleRequest: (self putRequestFor: 'http://localhost/doesNotExist' body: '1')) code equals: 404
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandleRequestReturnsLeafValueForNestedPath [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHandler new handleRequest: (ZnRequest get: 'http://localhost/browseTest/sub/b')) entity contents equals: '99'
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandleRequestReturnsMethodNotAllowedForNonGetRequests [
	"Only GET/PUT are implemented - DELETE stays disallowed."
	self assert: (CanopyBrowseHandler new handleRequest: (ZnRequest delete: 'http://localhost/browseTest/a')) code equals: 405
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandleRequestReturnsNotFoundForUnknownDomain [
	| response |
	response := CanopyBrowseHandler new handleRequest: (ZnRequest get: 'http://localhost/doesNotExist').
	self assert: response code equals: 404
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandleRequestReturnsNotFoundWhenPathContinuesPastALeaf [
	"a is a CanopyCell, not a CanopyBranchNode - navigating one level further must 404,
	not raise a raw doesNotUnderstand (CanopyCell/CanopyLeafNode do not implement /)."
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHandler new handleRequest: (ZnRequest get: 'http://localhost/browseTest/a/tooDeep')) code equals: 404
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandleRequestReturnsWholeTreeAsNestedJsonObjectWhenPathIsEmpty [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHandler new handleRequest: (ZnRequest get: 'http://localhost/')) entity contents
		equals: '{"browseTest":{"a":"x","sub":{"b":99}}}'
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandleRequestUsesConfiguredRootInsteadOfGlobalSingletonWhenSet [
	"root is overridable so a handler can browse an arbitrary subtree without touching the
	global Canopy singleton - useful for tests and for mounting a handler on a sub-branch."
	| customRoot handler |
	customRoot := CanopyBranchNode new.
	customRoot at: #onlyHere put: (CanopyCell new value: 'found').
	handler := CanopyBrowseHandler new root: customRoot.
	self assert: (handler handleRequest: (ZnRequest get: 'http://localhost/onlyHere')) entity contents equals: '"found"'
]
