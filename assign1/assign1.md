# Assignment 1: Swift and Extensions
**Due: Feb 16, 2020, 11:59:59 pm, v1**

## Goals
The primary goal of this project is to to familiarize yourself with the environment and
the language. All in this class will be written in Swift 5.1, using XCode 11 as your
friendly development environment. *Errors resulting from development in different
environments still result in loss of points.*  More importantly, `SwiftUI` will not work
on anything before Mojave.

Specifically, you will do the following:
1. create a standard single-view app, "*assign1*" that does nothing (other than
compile and show a blank screen), but does include a model of our app: "Triples".

In the process you will obviously learn quite a bit about the `XCode` environment, about
unit tests in the context of Swift applications, and about defining type extensions.

## Using git
We will use [*git*](https://git-scm.com/doc) ([cheat sheet](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&ved=2ahUKEwi_uaemsqXgAhVmzlkKHc-HCUkQFjABegQIAhAC&url=https%3A%2F%2Feducation.github.com%2Fgit-cheat-sheet-education.pdf&usg=AOvVaw2D3W2R0fwoOBi8YrhZYLFJ)) both to distribute starting files, for those projects that
have them (not `assign1`), and to submit the work that you create. Each of you will have had a single
gitlab repository create, e.g. `ios436spring2020/<dirid>` (but use your
directoryid, which is NOT a number). Clone this repository as follows:
1. log into gitlab and verify that you have the above repository
1. create and upload a public key as described below in "Upload Public Key". This will allow you to
   access gitlab via `ssh`, which is much less kludgy/buggy than https.
1. In your terminal window, clone via `git clone git@gitlab.cs.umd.edu:ios436spring2020/cmsc436-<dirid>` (again, use *your*
dirid). **cd** into this directory.
2. Establish a new *upstream remote*:  `git remote add upstream
   git@gitlab.cs.umd.edu:keleher/cmsc436spring2020-starter.git` This remote
   will be where you *pull* startup files from when each new project, or iteration of a
   project, is made available (`git pull upstream master'). **You will not
   need the upstream remote for this project, but set it up anyway.**
3. Verify your setup by executing `git remote -v`. You should see something
like:
```
origin	git@gitlab.cs.umd.edu:ios436spring2020/cmsc436-<dirid>.git (fetch)
origin	git@gitlab.cs.umd.edu:ios436spring2020/cmsc436-<dirid>.git (push)
upstream	git@gitlab.cs.umd.edu:keleher/cmsc436spring2020-starter.git (fetch)
upstream	git@gitlab.cs.umd.edu:keleher/cmsc436spring2020-starter.git (push)
```

Uploading your completed work is a two-step process: `git commit -m "a
label"`, followed by `git push origin master`. Verify by logging into the
gitlab website and making sure your new changes are there.

It's a good idea to
commit intermediate versions of your code many times during the development process.


### Upload Public Key
If you don't already have an RSA public key-pair, do the following:
```
    > cd
    > ssh-keygen -t rsa
      (hit return in response to all prompts)
```
Upload the contents of `~/.ssh/id_rsa.pub` to gitlab by logging in,
selecting 'Settings' from the menu in the upper right, and then selecting 'ssh
keys' from the left of the page. Add your key by pasting into the textbox,
giving your machine's name as a title, and clicking 'Add Key'.

    
# Building An App
We are going to build an apple called `Triples` in two or three stages. In the first
stage, we are just going to design and implement the model, and unit-test it.

As we did in class, you will create a new single-view iOS app:
- Create a new project in XCode and save to your `cmsc436-<dirid>` directory. 
- When creating the project:
  - also call it `assign1`
  - **check "unit tests"**, uncheck `git`, uncheck UI tests
  - select a "single-view" iOS app even though we will not have any graphical characteristics
- Note that new files must be explicitly added to git via `git add <file>...`.

Create a new file `model.swift` in the app by selecting "New File" from the, and then
selecting the Swift file icon in the dialog, and name it `model.swift`. 
`model.swift` will contain the "model" known from the model-view-controller (MVC) paradigm.

## App Logic
Our game action will be similar to the app `Threes` app on the apple and android app
stores. A portion of the game play is shown here:

![Similar gameplay](https://sedna.cs.umd.edu/clips/assign1DemoThrees.mp4)


## Your Tasks
Your tasks are to implement the gameplay shown in the clip. Specifically, you will
implement the "collapse", which given a swipe in a direction collapses each row or column
parallel to the swipe by eliminating a blank, combining a 1 and a 2, or combining two
consecutive tiles w/ the same value, 3 or higher.  For more specifics, see the tests
described below.

## The `Triples` Class

### Setup
```
func testSetup() {
        let game = Threes()
        game.newgame()
        
        XCTAssertTrue((game.board.count == 4) && (game.board[3].count == 4))
    }
```
Tests to ensure your app defines a 4x4 2D array of `Int`s.

### Rotate
Build a func `rotate2DInts` that will take any 2D Int array and rotate it once
clockwise. Your func may assume that the array is square.
```
    func testRotate1() {
        var board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        board = rotate2DInts(input: board)
        XCTAssertTrue(board == [[3,0,1,0],[3,2,2,3],[6,1,3,3],[6,3,3,3]])
    }
```

### Generic Rotate
Same test using a generic func you must write called `rotate2D`, and which will work on
any type of array.
```
    func testRotate2() {
        var board = [["0","3","3","3"],["1","2","3","3"],["0","2","1","3"],["3","3","6","6"]]
        board = rotate2D(input: board)
        XCTAssertTrue(board == [["3","0","1","0"],["3","2","2","3"],["6","1","3","3"],["6","3","3","3"]])
    }
```

### Generic Rotate Again
Try again with strings.
```
    func testRotate3() {
        let game = Threes()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.rotate()
        XCTAssertTrue(game.board == [[3,0,1,0],[3,2,2,3],[6,1,3,3],[6,3,3,3]])
    }
```

### Collapsing
Write a `shift()` method that collapses each row to the left (as if w/ a left swipe in the
clip). 
```
    func testShift() {
        let game = Threes()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.shift()
        XCTAssertTrue(game.board == [[3,3,3,0],[3,3,3,0],[2,1,3,0],[6,6,6,0]])
    }
```

Write and test a `collapse()` method will take a `Direction` enumeration collapse in the
direction specified. Internally, you should build `collapse` using `shift()` and `rotate()`.
```
    func testLeft() {
        let game = Threes()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.collapse(dir: .left)
        XCTAssertTrue(game.board == [[3,3,3,0],[3,3,3,0],[2,1,3,0],[6,6,6,0]])
    }

    func testRight() {
        let game = Threes()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.collapse(dir: .right)
        XCTAssertTrue(game.board == [[0,0,3,6],[0,1,2,6],[0,0,3,3],[0,3,3,12]])

    }

    func testDown() {
        let game = Threes()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.collapse(dir: .down)
        XCTAssertTrue(game.board == [[0,3,0,0],[0,2,6,3],[1,2,1,6],[3,3,6,6]])
    }

    func testUp() {
        let game = Threes()
        game.board = [[0,3,3,3],[1,2,3,3],[0,2,1,3],[3,3,6,6]]
        game.collapse(dir: .up)
        XCTAssertTrue(game.board == [[1,3,6,6],[0,2,1,3],[3,2,6,6],[0,3,0,0]])
    }
```

# Submit, and Grading
Submit by pushing your project to your 436 repository. **Check this** by visiting your
repository in a web browser at `https://gitlab.cs.umd.edu/ios436spring2020/cmsc436-<dirid>`

Each of the nine tests is worth 1 point. There is no partial credit.


# Notes
- Remember, frequently save your work on gitlab through:
```
    git add assign1
    git commit -m "a message"
    git push origin master
```
  This is exactly the same sequence you will use with the final submit. We will download
  your repository from gitlab directly.
