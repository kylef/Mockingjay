# Mockingjay Changelog
## Master

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

