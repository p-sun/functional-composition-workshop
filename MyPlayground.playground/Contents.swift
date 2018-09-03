/*

try! Swift
Understanding Function Composition with Setters Workshop
NYC, September 3rd, 2018

Taught by Stephen Celis
<https://twitter.com/stephencelis, stephencelis.com>

Notes by Paige Sun
<paige.sun.dev@gmail.com, github: p-sun>



Types of Functions:

--- Total function ---
	-- Total function ----- always returns an output for any input for an domain
		-- i.e.  identity function, additional of natural numbers, square
    -- Non-total function --
		-- anything with an optional
		-- divide by 0

- Deterministic
	-- Determinstic function ---- always return the same output for a given input

- Pure
	-- Pure -- no side effects and predictable. does not change the world (only computes a value)
    -- Inpure -- i.e. writing / reading from disk

**/

// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 1: Free functions
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// People often do this to keep namespaces separate and wrap static functions in a enum, but we don't need to

// 1.1 Method 1
enum Math {
	static func incr(_ x: Int) -> Int {
		return x + 1
	}
}

Math.incr(3)

// 1.2 Method 2
fileprivate  func incr(_ x: Int) -> Int {
	return x + 1
}

Math.incr(3)

// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 2
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// Free functions are already in Swift ------
// -- abs, zip, min, max, etc...
// -- Initializers
// -- Enum cases associated values
// -- Closures
// -- Static functions
// -- Operators

String.uppercased("hello")() // Note you have to call this one

"hi try Swift".uppercased()

// Another pure function

func square(_ x: Int) -> Int {
	return x * x
}

// Some people may not like using this, b/c it's not as readable, as we  have to read backwards, starting from the inner function.
// (i.e. incr() first, then square()
square(incr(2))
square // (Int) -> Int

let incrTheSquare = { square(incr($0)) }
// 2.incr().square()
// 2.incrThenSquare()

// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 3 -- Define a custom operator ----------------------------
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// There's no autocomplete for this, don't worry

// 3.1 Let's define the pipe operator |>
precedencegroup FunctionApplication {
	associativity: left // Whether left or right is more important
	higherThan: AssignmentPrecedence
}

infix operator |>: FunctionApplication
func |> <A, B> (a: A, f: (A) -> B) -> B {
	return f(a)
}

2 |> incr
2 |> incr |> square

// 3.1 Let's glue output of the left-hand function, to the input of the right-hand function
// f      //  (A) -> B
// >>>
// g     //            (B) -> C
//   -> ================
//            (A)          --> C

precedencegroup FunctionComposition {
	associativity: left
	higherThan: FunctionApplication
}

infix operator >>>: FunctionComposition
func >>> <A, B, C>(
	f: @escaping (A) -> B,
	g: @escaping (B) -> C)
	-> (A) -> C {
		return { g(f($0)) }
}

2 |> incr >>> square
incr >>> square

// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 4
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// --- Functional Composition --- Breaking code up into smaller pieces (often talked about as the opposite of to inheritance)
//     i.e. ViewControllers as functions with input and output
//       event of button click, to updating state

Array(Array(1...10).lazy.map(incr).map(square))
Array(1...10).map(incr >>> square >>> String.init)

// --- Higher Order function --- Anything that takes in a function, or anything that return a function

// 4.1 How is map defined?
func map1<A, B>(_ xs: [A], _ f: (A) -> B) -> [B] {
	return xs.map(f)
}

// 4.2 Alternatively, we can constrain the array to a Sequence instead
func map2<S: Sequence, B>(_ xs: S, _ f: (S.Element) -> B) -> [B] {
	return xs.map(f)
}

// 4.3 The curried version of map1
// What is currying?
// --- Currying --- Taking a function f(a, b) and splitting it to g(a)(b),
// where g(a) returns a FUNCTION that returns h(b)
func map3<A, B>(_ xs: [A]) -> ((A) -> B) -> [B] {
	return { f in xs.map (f) }
}

// 4.4 A function that creates a typed map function
func mapGenerator<A, B>(
	_ f: @escaping (A) -> B)
	-> ([A]) -> [B] {
	return { xs in xs.map(f) }
}

Array(1...10)
	|> mapGenerator(incr) >>> mapGenerator(square)

mapGenerator(incr >>> square)

// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 5
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// Composing higher order functions
// --- Composition --- is gluing higher order functions together, so that the output of one is the input of another

// 5.1
func filter<A> (
	_ f: @escaping (A) -> Bool)
	-> ([A]) -> [A] {
		return { xs in xs.filter(f) }
}

let isEven = { $0 % 2 == 0 }

Array(1...10)
	|> mapGenerator(incr) // [Int] -> [Int]
	>>> filter(isEven)         // [Int] -> [Int]

// 5.2
let isOdd = incr >>> isEven

// 5.3
func incrFirst(_ pair: (Int, String)) -> (Int, String) {
	return (incr(pair.0), pair.1)
}

let pair = (42, "Hello")
incrFirst(pair)

// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 6
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// ((A) -> B) ->    ([A])        -> [B]
//  (A) -> B)  ->   (( A, C))     -> (B, C)
// --- Setter function ---
//		Purpose: Transform -a part- of a structure
//   	Input: Transform Function of a single -a part-
//   	Output: Transform Function of a whole structure

// 6.1 Define setter that transforms pair.0
func mapFirst<A, B, C>(
	_ f: @escaping (A) -> B)
	-> ((A, C)) -> (B, C) {
		return { pair in (f(pair.0), pair.1) }
}

let incrFirst2: ((Int, String)) -> (Int, String) = mapFirst(incr)
pair |> mapFirst(incr)

// 6.2 Define setter that transforms pair.1
func mapSecond<A, B, C>(
	_ f: @escaping (A) -> B)
	-> ((C, A)) -> (C, B) {
		return { pair in (pair.0, f(pair.1)) }
}

// 6.3.1 -- Use mapFirst to map pair.0
pair
	|> mapFirst(incr)
	>>> mapFirst(square)
	>>> mapFirst(String.init)

// 6.3.2 -- Same result as 6.3.1.
// Note that we can refactor 6.3.1 by composing the 3 functions together so it's more performance
pair
	|> mapFirst(incr >>> square >>> String.init)

// 6.3.3 -- Now we can use the mapSecond function to map pair.1
pair
	|> mapFirst(incr >>> square >>> String.init)
	>>> mapSecond { $0.count }

// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 7
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// Goal, try to use mapFirst and mapSecond onto this nested structure
let nested = ("Hello", (42, "World"))

// Hint: We can nest our setters like this:
[[1, 2], [3, 4]].map { subarray in
	subarray.map { int in
		incr(int)
	}
}

// 7.1 -- Answer
nested |> mapSecond { second in
	second |> mapFirst { first in
		incr(first)
	}
}

// 7.2 -- Refactored version of 7.1
nested |> mapSecond { second in
	second |> mapFirst(incr)
}

// 7.3 -- Refactored even further. Same as 7.1 and 7.2.
nested |> (mapFirst >>> mapSecond)(incr)

// 7.4 -- Create an operator that composes in the opposite direction as >>>
infix operator <<<: FunctionComposition
func <<< <A, B, C>(
	f: @escaping (B) -> C,
	g: @escaping (A) -> B)
	-> (A) -> C {
		return { f(g($0)) }
}

nested  |> (mapSecond <<< mapFirst)(incr)


// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 8
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// --- keyPath ---

// 8.1 You can use keyPaths to access variables in structs.

struct User {
	var name: String
	var location: String
	var age: Int
}

var user = User(name: "Blob", location: "NYC", age: 42)

user[keyPath: \User.name]
user[keyPath: \User.name] = "Blob 2"
user.name
user.name = "Blob"

// 8.2
func propertySetter<Root, Value>(
	_ keyPath: WritableKeyPath<Root, Value>
	) -> (@escaping (Value) -> Value) -> ((Root) -> Root) {
	return { transform in
		return { r in
			var root = r
			root[keyPath: keyPath] = transform(root[keyPath: keyPath])
			return root
		}
	}
}

let userAgeSetter = propertySetter(\User.age)
let userAgeIncreamenter = userAgeSetter(incr)
let incrementedUser = userAgeIncreamenter(user) // Note that `user`'s age is 42
incrementedUser.age // now it's 43! 🕺💃

// 8.3
user.age
let newUser = user
	|> propertySetter(\.age)(incr)
newUser.age

// 8.4
let newUser2 = user
	|> propertySetter(\.age)(incr)
	>>> (propertySetter(\.name)) { $0.uppercased() }
newUser2.age
newUser2.name

// 8.5
[user, user, user]
	|> mapGenerator(propertySetter(\.age)(incr)
		>>> (propertySetter(\.name)) { $0.uppercased() })

// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
// Demo 9
// ~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

// Real World Examples of clerning code up with `prop` (i.e. propertySetter) and `set`
import UIKit

// 9.1
let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.alignment = .center

func set<Root, Value>(
	_ kp: WritableKeyPath<Root, Value>,
	_ value: Value
	)
	-> (Root) -> Root
{
	return (propertySetter(kp)) { _ in value }
}

NSMutableParagraphStyle()
	|> set(\.alignment, .center)

// 9.2
let autolayoutStyle = set(\UIView.translatesAutoresizingMaskIntoConstraints, true)
UIView() |> autolayoutStyle

class MyViewController: UIViewController {
	let subtitleLabel = UILabel()
		|> set(\.font, .systemFont(ofSize: 17))
		>>> set(\.textColor, .blue)				  // These two do the same thing
		>>> set(\.textColor, .some(.blue))  // These two do the same thing
}

// 9.3
private let dataFormatter = DateFormatter()
	|> set(\.dateStyle, .long)

// 9.4 --- Wow, so cool.
let labelColorStyle = { color in
	set(\UILabel.textColor, color)
}
let primaryLabelStyle = labelColorStyle(.green)
let titleLabel = UILabel()
	|> primaryLabelStyle

/*
More Resources:

Open Source Book -- Professor Frisby's mostly adequate guide to functional programming!
https://github.com/MostlyAdequate/mostly-adequate-guide

Videos accompaning the Frisby book
https://egghead.io/courses/professor-frisby-introduces-composable-functional-javascript

Stephen Celis's functional programming podcast!
https://www.pointfree.co/

Why functional? A guide to software architecture.
https://www.destroyallsoftware.com/talks/boundaries

**/
