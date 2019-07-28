#  CodingTaskMapApp

An app that shows a list of things on a map.

## My design goals

1. This is a mobile app, so we should cope with network disconnects
2. The user should never be confused whether all data is there or not (hence progress indicators)
3. Given #2, the user should also never be presented an empty map or list without being explicitly told that there is nothing to see, nor be unsure what a list is supposed to show (therefore text on empty lists saying "no cars available at this time", which also indicates there _would_ be cars)
4. The task description doesn't say anything about a detail view, so leaving that out, but sharing a MapController to show I know how passing some info _would_ work in Storyboards.
5. Threading code is complex and error-prone. The threading strategy for this app is "do this long-running operation on a thread, call me back on the main thread when you're done". We can always move to a complex threaded design for the cases where performance or concurrency is really critical. Usually it isn't.

## Shortcuts taken

- No reloading. We have a file, not a back-end, so we get no change notifications, so that'd be a boring demo anyway
- We have no reloading, so we don't monitor network status. We just keep showing previous state, which in most cases is best anyway (short drop-out doesn't kick the user out of their screen if all they did was read data that wouldn't have changed anyway). We do display an error message if a request fails due to no network, and re-load on entering a screen. We also make no attempt at coalescing "network down" errors, as we can only get one error for the JSON, when entering a screen (we quietly use a placeholder for errors on images, they're not that important). A real app would likely have to make that effort.
- No tests of the network code - To be a reliable test, one would have to mock them.
- ImageCache doesn't flush its cache.
- One would probably make a URLSessionTask category that does the initial checks for errors and connectivity and reports the errors somewhere that coalesces them. Since we have two URL requests and one doesn't report errors, we're leaving that chunk of code there for now.
- The app uses print() unconditionally. Every company already has their favorite logging library that doesn't log in release builds, I'm sure you can imagine it changed over to that.
- This code is all MVC, with distinction between view controllers and more model-facing controllers (not the usual "it's a controller so must be a subclass of NSViewController" mis-apprehension). There are many other patterns I could have used, I just picked this because it involves the least fighting against UIKit and I didn't want to pull in additional dependencies for a small example. 

## Third-party code

- Every company already has their favorite Reachability implementation. I just grabbed one by a well-known person that was free to use and wasn't ObjC.
