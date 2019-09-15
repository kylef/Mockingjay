# Mockingjay Changelog

## 3.0.0-alpha.1

### Breaking

- Support for Swift < 4.2 has been removed.

### Enhancements

- Adds support for Swift 5.0.

## 2.0.1

### Enhancements

- You can now specify a delay option to a stub to simulate network delays.
- Adds support for building Mockingjay with Swift 4.

## 2.0.0 (2016-10-07)

### Breaking

- Responses now use a `Download` enum instead of an optional `NSData`. This
    means you must use the following API:

    ```swift
    .Success(response, .NoContent)
    .Success(response, .Content(data))
    ```

    Previously:

    ```swift
    .Success(response, nil)
    .Success(response, data)
    ```

### Enhancements

- Adds support for streaming stubbed response data.

    ```swift
    .Success(response, .StreamContent(data, inChunksOf: 1024))
    ```

## 1.3.0 (2016-09-28)

This release adds support for Swift 2.3.


## 1.2.1 (2016-05-10)

This release fixes a packaging problem in 1.2.0 where the CocoaPod's podspec
for Mockingjay did not contain all the sources.


## 1.2.0 (2016-05-10)
### Enhancements

- Swift 2.2 support has been added.

### Bug Fixes

- Mockingjay will now add it's own protocol to `NSURLSessionConfiguration`
  default and ephemeral session configuration on load. This fixes problems when
  you create a session and then register a stub before we've added the
  Mockingjay protocol to `NSURLSessionConfiguration`.  
  [#50](https://github.com/kylef/Mockingjay/issues/50)

