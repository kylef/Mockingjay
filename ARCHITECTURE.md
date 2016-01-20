# Mockingjay Architecture

This document outlines the architecture of Mockingjay.

## `MockingjayProtocol`

Under the hood, Mockingjay registers it's own `NSURLProtocol`
(`MockingjayProtocol`). This class keeps track of registered stubs. It's also
the base for stubbing any requests.

When you make a request via `NSURLConnection` or `NSURLSession`, these
mechanisms will run though the registered `NSURLProtocol`s, including
`MockingjayProtocol` and ask them all if they `canInitWithRequest`.
This method in `MockingjayProtocol` will determine if the given request
matches any stub and returns true if there is a stub. `NSURLConnection`
or `NSURLSession` will pick the first `NSURLProtocol` that returns true
to `canInitWithRequest` to handle the request.

`MockingjayProtocol` will look though the registered stubs backwards in search
for the last registered stub that matched the request.

Later, `startLoading` is called on the protocol. In `MockingjayProtocol`, this
method will relay the stubbed response to the user.
