//
//  GeneratorPartsTests.swift
//  guaka-cli
//
//  Created by Omar Abdelhafith on 27/11/2016.
//
//

import XCTest
@testable import GuakaClILib

class GeneratorPartsTests: XCTestCase {

  func testGeneratesCommandFile() {
    let file = GeneratorParts.commandFile(forVarName: "test", commandName: "testit")
    let expectedFile = """
      import Guaka

      var testCommand = Command(
          usage: "testit",
          configuration: configuration,
          run: execute
      )

      private func configuration(command: Command) {
          command.add(flags: [
              // Add your flags here
          ])

          // Other configurations
      }

      private func execute(flags: Flags, args: [String]) {
          // Execute code here
          print("testit called")
      }

      """
    XCTAssertEqual(file, expectedFile)
  }

  func testGeneratesPackageFile() {
    let file = GeneratorParts.packageFile(forCommandName: "test")
    let expectedFile = """
      // swift-tools-version:4.0
      import PackageDescription

      let package = Package(
          name: "test",
          dependencies: [
              .package(url: "https://github.com/oarrabi/Guaka.git", from: "0.0.0"),
          ],
          targets: [
              .target(
                  name: "test",
                  dependencies: ["Guaka"]),
              .testTarget(
                  name: "testTests",
                  dependencies: ["test"]),
          ],
      )

      """
    XCTAssertEqual(file, expectedFile)
  }

  func testGeneratesMainFile() {
    let file = GeneratorParts.mainSwiftFileContent()
    XCTAssertEqual(file, "import Guaka\n\nsetupCommands()\n\nrootCommand.execute()\n")
  }

  func testGeneratesSetupFile() {
    let file = GeneratorParts.setupFileContent()
    let expectedFile = """
      import Guaka

      // Generated, don't update
      func setupCommands() {
          // Command adding placeholder, edit this line
      }

      """
    XCTAssertEqual(file, expectedFile)
  }

  func testUpdatesSetupWithoutParentFile() {
    let file = GeneratorParts.setupFileContent()
    let updated = try! GeneratorParts.updateSetupFile(withContent: file, byAddingCommand: "new", withParent: nil)
    let expected = """
      import Guaka

      // Generated, don't update
      func setupCommands() {
          rootCommand.add(subCommand: new)
          // Command adding placeholder, edit this line
      }

      """
    XCTAssertEqual(updated, expected)
  }

  func testUpdatesSetupWithParentFile() {
    let file = GeneratorParts.setupFileContent()
    let updated = try! GeneratorParts.updateSetupFile(withContent: file, byAddingCommand: "new", withParent: "root")
    let expected = """
      import Guaka

      // Generated, don't update
      func setupCommands() {
          rootCommand.add(subCommand: new)
          // Command adding placeholder, edit this line
      }

      """
    XCTAssertEqual(updated, expected)
  }

  func testItThrowsErrorIfCannotFindThePlaceholder() {
    do {
      _ = try GeneratorParts.updateSetupFile(withContent: "abcd", byAddingCommand: "new", withParent: "root")
    } catch let e as GuakaError {
      XCTAssertEqual(e.error, """
        Guaka setup.swift file has been altered.
        The placeholder used to insert commands cannot be found // Command adding placeholder, edit this line.
        You can try to add it yourself by updating `setup.swift` to look like

        import Guaka

        // Generated, don't update
        func setupCommands() {
            // Command adding placeholder, edit this line
        }

        Adding command won't be possible."
        """.f.red)
    } catch {
      XCTFail()
    }
  }

  func testCanUpdateFileMultipleTimes() {
    let file = GeneratorParts.setupFileContent()
    var updated = try! GeneratorParts.updateSetupFile(withContent: file, byAddingCommand: "new1", withParent: "root")

    updated = try! GeneratorParts.updateSetupFile(withContent: updated, byAddingCommand: "new2")

    updated = try! GeneratorParts.updateSetupFile(withContent: updated, byAddingCommand: "new3")

    XCTAssertEqual(updated, """
      import Guaka

      // Generated, don't update
      func setupCommands() {
          rootCommand.add(subCommand: new1)
          rootCommand.add(subCommand: new2)
          rootCommand.add(subCommand: new3)
          // Command adding placeholder, edit this line
      }

      """)
  }

  func testItGetsNameIfCorrect() {
    let name = try! GeneratorParts.commandName(forPassedArgs: ["name"])
    XCTAssertEqual(name, "name")
  }

  func testItThrowsErrorIfArgsIsEmpty() {
    do {
      _ = try GeneratorParts.commandName(forPassedArgs: [])
    } catch let e as GuakaError {
      XCTAssertEqual(e.error, [
        "Missing CommandName for `guaka add`.".f.red,
        "",
        "Call `guaka add CommandName` to create a new command.",
        ""
        ].joined(separator: "\n"))
    } catch {
      XCTFail()
    }
  }

  func testItThrowsErrorIfMoreThan1ArgsArePassed() {
    do {
      _ = try GeneratorParts.commandName(forPassedArgs: ["a", "b"])
    } catch let e as GuakaError {
      XCTAssertEqual(e.error, "Too many arguments passed to command.".f.red)
    } catch {
      XCTFail()
    }
  }

  func testItThrowsErrorIfWrongNamePassed() {
    do {
      _ = try GeneratorParts.commandName(forPassedArgs: ["abc def"])
    } catch let e as GuakaError {
      XCTAssertEqual(e.error, "The command name passed `abc def` is incorrect.".f.red + "\nPlease use only letters, numbers, underscodes and dashes.\n\nValid examples:\n   guaka new test\n   guaka new MyCommand\n   guaka new my-command\n   guaka new my_command\n   guaka new myCommand")
    } catch {
      XCTFail()
    }
  }

  func testItReturnsNilIfProjctNameIsEmpty() {
    let name = try! GeneratorParts.projectName(forPassedArgs: [])
    XCTAssertNil(name)
  }

  func testItReturnsNameIfProjectNameIsCorrect() {
    let name = try! GeneratorParts.projectName(forPassedArgs: ["abc"])
    XCTAssertEqual(name, "abc")
  }

  func testItThrowsErrorIfProjectNameContainsSpaces() {
    do {
      _ = try GeneratorParts.projectName(forPassedArgs: ["abc asdsa"])
    } catch GuakaError.wrongCommandNameFormat {
    } catch {
      XCTFail()
    }
  }

  func testItThrowsErrorIfProjectReceivedTooManyArgs() {
    do {
      _ = try GeneratorParts.projectName(forPassedArgs: ["abc", "asdsa"])
    } catch GuakaError.tooManyArgsPassed {
    } catch {
      XCTFail()
    }
  }

  static let allTests = [
    ("testGeneratesCommandFile", testGeneratesCommandFile),
    ("testGeneratesPackageFile", testGeneratesPackageFile),
    ("testGeneratesMainFile", testGeneratesMainFile),
    ("testGeneratesSetupFile", testGeneratesSetupFile),
    ("testUpdatesSetupWithoutParentFile", testUpdatesSetupWithoutParentFile),
    ("testUpdatesSetupWithParentFile", testUpdatesSetupWithParentFile),
    ("testItThrowsErrorIfCannotFindThePlaceholder", testItThrowsErrorIfCannotFindThePlaceholder),
    ("testCanUpdateFileMultipleTimes", testCanUpdateFileMultipleTimes),
    ("testItGetsNameIfCorrect", testItGetsNameIfCorrect),
    ("testItThrowsErrorIfArgsIsEmpty", testItThrowsErrorIfArgsIsEmpty),
    ("testItThrowsErrorIfMoreThan1ArgsArePassed", testItThrowsErrorIfMoreThan1ArgsArePassed),
    ("testItThrowsErrorIfWrongNamePassed", testItThrowsErrorIfWrongNamePassed),
    ("testItReturnsNilIfProjctNameIsEmpty", testItReturnsNilIfProjctNameIsEmpty),
    ("testItReturnsNameIfProjectNameIsCorrect", testItReturnsNameIfProjectNameIsCorrect),
    ("testItThrowsErrorIfProjectNameContainsSpaces", testItThrowsErrorIfProjectNameContainsSpaces),
    ("testItThrowsErrorIfProjectReceivedTooManyArgs", testItThrowsErrorIfProjectReceivedTooManyArgs),
  ]
}
