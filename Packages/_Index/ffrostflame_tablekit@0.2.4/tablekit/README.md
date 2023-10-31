# TableKit
TableKit is a *kit* of functions to help manipulate & utilize tables more effectively. It contains various functions that have
real-world use cases such as .Reconcile(), .DeepCopy(), .Unshift(), etc.

## Documentation
https://ffrostflame.github.io/TableKit/

## Why?
I made this project primarily because there were no up-to-date & high quality table manipulation libraries out there. None suited my needs-
I wanted something I could plug in with Wally, something fully typed, and using modern-day Luau functions. This doesn't exist.

## Advantages
- This is mainly for my personal usage- which means that it will be updated any time I need a new feature.
- I use it in my open source packages (at the moment, 2 unreleased) as well.
- It's up-to-date with Luau features. This means it uses generic iteration, all of the built-in `table` functions, etc.
- It's fully typed.

## Disadvantages
- It's another dependency for your project. However, if you're going to do these yourself, you might as well use this.

## Prior Art / Inspiration
- TableUtils by sleitnick
- Javascript Array objects- you'll see a few things taken from there such as .Unshift().
