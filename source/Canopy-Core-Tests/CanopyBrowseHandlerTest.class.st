Class {
	#name : 'CanopyBrowseHandlerTest',
	#superclass : 'TestCase',
	#category : 'Canopy-Core-Tests',
	#package : 'Canopy-Core-Tests'
}

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
CanopyBrowseHandlerTest >> testHandleRequestReturnsLeafValueForNestedPath [
	[ self registerBrowseTestDomain.
	self assert: (CanopyBrowseHandler new handleRequest: (ZnRequest get: 'http://localhost/browseTest/sub/b')) entity contents equals: '99'
	] ensure: [ Canopy reset ]
]

{ #category : 'tests' }
CanopyBrowseHandlerTest >> testHandleRequestReturnsMethodNotAllowedForNonGetRequests [
	"Only GET is implemented so far (PR: HTTP Browse-Handler, GET). PUT (write) follows in a
	separate PR - DELETE is used here so this test stays valid once PUT is added."
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
