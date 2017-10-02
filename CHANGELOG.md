# Change Log

## [0.9.3](https://github.com/Flipkart/Swifty/releases/tag/0.9.3)
Released on 2017-10-02.

#### Added
- JSON Parsing Interceptor now also parses the JSON returned in an error response, and puts the results into the NSError's `userInfo` property
- Added new Tests for JSON Parsing, Server Error Codes, Empty Response Codes
- Updated Example Project according to Xcode 9 Recommendations

#### Fixed
- Response Validation Error now carries over the HTTP Error Code (if available) as it's error code
- Fixed major issue in which the Response Validation logic might fallthrough incorrectly
- `.loadJSON()` now handles Empty Responses properly

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