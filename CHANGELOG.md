# Change Log

## [0.9.2](https://github.com/Flipkart/Swifty/releases/tag/0.9.2)
Released on 2017-09-20.

#### Added
- New `.authorizationHeader()` modifier to add a Basic Hidden HTTP `Authorization` header to a resource
- Support for chaning multiple `.query()` methods on a resource
- Tests for `WebService` Modifiers

#### Fixed
- Bug due to which `NetworkResourceWithBody` methods could not be chained after using a `NetworkResource` modifier due to return type ambiguity

## [0.9.1](https://github.com/Flipkart/Swifty/releases/tag/0.9.1)
Released on 2017-09-13.

#### Fixed
- Swifty Inspector's table view reload being called on a background thread

## [0.9.0](https://github.com/Flipkart/Swifty/releases/tag/0.9.0)
Released on 2017-09-12.

#### Added
- Initial release of Swifty.