# Mockingjay

[![Build Status](http://img.shields.io/travis/kylef/Mockingjay.swift/master.svg?style=flat)](https://travis-ci.org/kylef/Mockingjay.swift)

An elegant library for stubbing HTTP requests in Swift, allowing you to stub any HTTP/HTTPS using `NSURLConnection` or `NSURLSession`. That includes any request made from libraries such as [Alamofire](https://github.com/Alamofire/Alamofire) and [AFNetworking](https://github.com/AFNetworking/AFNetworking).

## Installation

```ruby
pod 'Mockingjay'
```

## Usage

Mockingly has full integration to XCTest and you simply just need to register a stub, it will automatically be unloaded at the end of your test case.

#### Simple stub using a URI Template, returning a response with the given JSON encoded structure

```swift
let body = [ "user": "Kyle" ]
stub(uri("/{user}/{repository}"), json(body))
```

The `uri` function takes a URL or path which can have a [URI Template](https://github.com/kylef/URITemplate.swift). Such as the following:

- `https://github.com/kylef/WebLinking.swift`
- `https://github.com/kylef/{repository}`
- `/kylef/{repository}`
- `/kylef/URITemplate.swift`

#### Stubbing a specific HTTP method with a JSON structure

```swift
let body = [ "description": "Kyle" ]
stub(http(.PUT, "/kylef/Mockingjay"), json(body))
```

#### Stubbing everything request to result in an error

```swift
let error = NSError()
stub(everything, failure(error))
```

#### Stub with a specific HTTP response

```swift
stub(everything, http(404))
```

*Note, the `http` builder can take a set of headers and a body too.*

## Stub

The `stub` method in Mockingly takes two functions or closures, one to match the request and another to build the response. This allows you to easily extend the syntax to provide your own specific functions.

### Matchers

A matcher is simply a function that takes a request and returns a boolean value for if the stub matches the request.

```swift
func matcher(request:NSURLRequest) -> Bool {
  return true  // Let's match this request
}

stub(matcher, failure(error))
```

### Builders

Builders are very similar to a matcher, it takes a request, and it returns either a success or failure response.

```swift
func builder(request:NSURLRequest) -> Response {
  let response = NSHTTPURLResponse(URL: request.URL, statusCode: 200, HTTPVersion: nil, headerFields: nil)!
  let data:NSData? = nil
  return .Success(response, data)
}

stub(matcher, builder)
```

## API Blueprint

![API Blueprint](https://raw.githubusercontent.com/apiaryio/api-blueprint/master/assets/logo_apiblueprint.png)

Mockingjay comes with complete support for the API Blueprint language. Which allows you to stub all of your requests directly from your API description.

To stub all requests from an API Blueprint, you will first need to convert it into it’s AST form in JSON. For this, you can use [Snow Crash](https://github.com/apiaryio/snowcrash).

```bash
snowcrash -o palaver.apib.json -f json palaver-api-docs/palaver.apib
```

Then you can simply add the resultant JSON file into your test bundle and then load it in your tests:

```swift
func setUp() {
  super.setUp()

  let blueprint = Blueprint(named:"palaver.apib.json")
}
```

## License

Mockingjay is licensed under the BSD license. See [LICENSE](LICENSE) for more
info.

