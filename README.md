![Swifty Logo](https://raw.githubusercontent.com/Flipkart/Swifty/master/Swifty.png)

[![Build Status](https://travis-ci.org/Flipkart/Swifty.svg?branch=master)](https://travis-ci.org/Flipkart/Swifty)
[![Version](https://img.shields.io/cocoapods/v/Swifty.svg?style=flat)](http://cocoapods.org/pods/Swifty)
[![Platform](https://img.shields.io/cocoapods/p/Swifty.svg?style=flat)](http://cocoapods.org/pods/Swifty)
[![Swift](https://img.shields.io/badge/swift-4-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Docs](https://img.shields.io/badge/Docs-awesome-12a49f.svg)](https://flipkart.github.io/Swifty)
[![License](https://img.shields.io/cocoapods/l/Swifty.svg?style=flat)](http://cocoapods.org/pods/Swifty)

Swifty is a modern take on how iOS apps should do networking. Written in Swift, it offers a **declarative** way to write your network requests and organise them, abstracting the networking away from the call-site, while giving you full control into every aspect of the actual network communication.

## Swifty is built to primarily answer three common questions developers ask when building a modern app:

1. Where do I keep my network requests?
2. Where do I write my custom OAuth/Authentication/Session logic? Or how do I manage things like Session across my requests?
3. How should I do the actual networking? URLSession?

## Where do I keep my network requests?

Swifty offers a protocol called ```WebService``` which helps you write your network requests in a type-safe and expressive way. 

You start by **creating a class**, putting in your **server's base URL** & a network interface, and begin writing your **network requests as functions**:


~~~swift
class GithubAPI: WebService {

	/* Your Server's Base URL */
	static var serverURL = "https://api.github.com"
	
	/* What this WebService will use to actually make the network calls */
	static var networkInterface: WebServiceNetworkInterface = Swifty.shared
	
	/* Your network requests, as type-safe functions: */
	
	static func getAPIStatus() -> NetworkResource {
		return server.get("status")
	}
	
	static func getRespositories(for user: String) -> NetworkResource {
		return server.get("repositories")
			     .query("user": user)
	}
	
	static func createGist(with body: String) -> NetworkResource {
		return server.post("gists")
		 	     .json("body": body)	
	}
	
}
~~~

#### A few things to notice above: 
- Each of your network request functions return a ```NetworkResource```. This is basically a **wrapper over ```URLRequest```**, with extra stuff to support this cool syntax and other features.
- You write each request starting with the ```server``` variable (which is the server URL you defined above converted into a ```NetworkResource```), chaining methods to it like ```.get()```, ```.post```, and ```.query()``` to create the actual request. The full list of these modifiers is [available here](https://flipkart.github.io/Swifty/Classes/NetworkResourceWithBody.html).
- The variable ```networkInterface``` is a way of telling this ```WebService``` what library to use to *actually make the network request*. For this example, we're directly using Swifty.

> **Super Cool Stuff**: These chaining methods are compile time checks, for example, you can't chain a ```.json()``` to a GET request, because it doesn't support a body payload 😎 

### Usage
Requests written in **WebService** are accessible from both **Swift** and **Objective-C** callers!

#### Swift

~~~swift
class ViewController: UIViewController {

    override viewDidLoad(){
        
        GithubAPI.getStatus().load(){ (response, data, error) in
            // Do something with the response
        }
        
    }
}
~~~

#### Objective-C

~~~objectivec

@implementation ViewController: UIViewController {

- (void) viewDidLoad {
        
    [GithubAPI getStatus] load:^(NSURLResponse *response, id data, NSError *error){
        // Do something with the response
    }];

}

@end
~~~
> *These are examples, please don't directly write networking code in your view controllers :)*

## Where do I write my custom OAuth/Authentication/Session logic?

Modern Apps usually access APIs that are behind authentication or rate limiting systems, and they need to send these tokens with every request they send.

This is normally a convoluted process: First, check if we already have a valid token. If we don't, we need to get one, and then start attaching it to every request we send. And of course, take care of the error conditions in all these cases. This process can quickly lead to a code duplication and callback hell at multiple places if not done properly.

Swifty understands this requirement, and provides constructs to effectively encapsulate these into thread-safe processes using ```Constraints``` & ```Interceptors```

***

### Constraints

Constraints are tasks which can *hold* network requests from starting until they are satisfied. 

> *Constraints can be any task, not just network requests: they can even be simple things like asking for location access permission before firing a request.*

A common use of a constraint would be an **OAuth Constraint**, which makes sure you have an OAuth token before your requests start.

To create a constraint, just subclass ```Constraint```, and override the two required methods:

~~~swift
class OAuthConstraint: Constraint {

	override func isConstraintSatisfied(for resource: NetworkResource) -> Bool {
		// return false if we don't have the OAuth Token
		// return true if we already have the OAuth Token
	}
	
	override func satisfyConstraint(for resource: NetworkResource) {
		// Get the OAuth token from the server
		// Make sure to call finish() when done
		finish()
	}
}
~~~

#### How does it work?
- Swifty will automatically call your Constraint's ```isConstraintSatisfied``` for every resource that passes through it. This method is synchronous but thread-safe, and needs to return ```true``` or ```false```:
	- If your return ```true```, then the request will resume, subject to the satisfaction of other constraints.
	- In you return ```false```, Swifty will asynchronously call your ```satisfyConstraint``` method, and here you can perform any operation as required. Just make sure you call ```finish``` when done, so that Swifty can resume the requests that were waiting on your constraint.
		- You can even finish with an ```error```. If you do, the requests that were waiting on your constraint, will automatically fail with the same error.
- You can decide what to do in both these methods selectively based on the requests, since the NetworkResource is passed as an argument each time when these are called.

***

### Interceptors

Interceptors are methods which are called before and after every request. There are two types: ```Request Intereptors``` and ```Response Interceptors```

#### Request Interceptors 

Request Interceptors are called just before a request is about to fire over the network. Request Interceptors are called **after** all the constraints of a request a satisfied, but just **before** a request is about to go over the network. This makes them especially useful to add parameters to the requests they need to succeed. 

For example, an interceptor can be used to attach an OAuth token that a constraint might have just receieved from a server. 

To create a ```RequestInterceptor```, simply create a class/struct that conforms to the ```RequestInterceptor``` protocol, and implement the one required method:

~~~swift
class OAuthTokenAddingInterceptor: RequestInterceptor {

	func intercept(resource: NetworkResource) -> NetworkResource {
		
		// Get the token from where your Constraint might have saved it, this is just an example here: 
		let token = Keychain.string(key: "OAuth")
		
		// Attach it to the resource:
		resource.header(key: "Token", value: token)
		
		// Return the modified resource
		return resource
	}

}
~~~

#### Response Interceptors 

Response Interceptors are called just before a response is going to be returned back to the caller. 

You can do a lot of things here, for example:

- Collect/Log statistics about the failure rate of responses by counting the number of errors
- Update your session information from every response, if they have any
- You can even force ```succeed``` or force ```fail``` your responses in Response Interceptors

For the *sake of example*, if your API considers a 204 response a failure, we can create a ```ResponseInterceptor``` to check for this status code in every response, and force fail responses if encountered. 

~~~swift
class ErrorCheckingInterceptor: ResponseInterceptor {

	func intercept(response: NetworkResponse) -> NetworkResponse {
		
		// Check for the 204 status code in the response 
		if let statusCode = response.response?.statusCode, statusCode == 204 {
			// Fail the response with a responseValidation error
			response.fail(error: SwiftyError.responseValidation()) // Now this response will invoke the failureBlock, instead of the successBlock of the caller.
		}
		
		return response
	}

}
~~~


#### Things to note about Interceptors: 
- Each of your network requests pass through all the interceptors, both ```RequestInterceptors``` and ```ResponseInterceptors```.
- The requests pass through the interceptors *in the order* that you provide them to Swifty.

## How should I do the actual networking? URLSession?

Swifty is built on top of `URLSession`, and is what powers the actual network communication in all the above constructs.

Swifty abstracts away URLSession's little details, while still giving you granular control where it matters.

Remember that `networkInterface` property on your WebService? When you're done writing your requests in your `WebService`, and have put in your business logic in `Constraints` & `Interceptors`, you bring it all together by adding your customisations into the initializer of `Swifty` in your `WebService`!

~~~swift
class GithubAPI: WebService {

	...
		
	/* What this WebService will use to actually make the network calls */
	static var networkInterface: WebServiceNetworkInterface = Swifty(constraints: [OAuthConstraint()], 
	   requestInterceptors: [OAuthTokenAddingInterceptor()],
	   responseInterceptors: [ErrorCheckingInterceptor()])
		
	...
	
}
~~~

And that's it! Everything comes together, and all your ```WebService``` requests go through your ```Swifty's``` customised pipeline of ```Constraints``` and ```Interceptors```, when you call ```.load()``` on them.

## API Documentation

The full documentation for Swifty is [available here.](https://flipkart.github.io/Swifty)

## Installation

### CocoaPods

To integrate Swifty into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Swifty'
```

Then, run the following command:

```bash
$ pod install
```

## Requirements

- iOS 8.0+
- Swift 4.2

---

[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=flipkart/swifty)](http://clayallsopp.github.io/readme-score?url=flipkart/swifty)