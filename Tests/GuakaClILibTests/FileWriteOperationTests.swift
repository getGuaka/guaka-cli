//
//  FileWriteOperationTests.swift
//  guaka-cli
//
//  Created by Omar Abdelhafith on 27/11/2016.
//
//

import XCTest
@testable import GuakaClILib


class FileWriteOperationTests: XCTestCase {

  override func setUp() {
    super.setUp()
    MockDirectoryType.clear()
    MockFileType.clear()
  }

  func testCreateNewWriteOperationsWithPackage() {
    let operations = FileOperations.newProjectOperations(paths: Paths(rootDirectory: "/root/abcd"))
    let op = operations.operations.filter { $0.filePath.contains("Package.swift") }.first! as! FileWriteOperation

    XCTAssertEqual(op.filePath, "/root/abcd/Package.swift")
    XCTAssertEqual(op.fileContent, GeneratorParts.packageFile(forCommandName: "abcd"))
    XCTAssertEqual(op.errorString, "package")
  }

  func testCreateNewWriteOperationsWithMain() {
    let operations = FileOperations.newProjectOperations(paths: Paths(rootDirectory: "/root/abcd"))
    let op = operations.operations.filter { $0.filePath.contains("main.swift") }.first! as! FileWriteOperation

    XCTAssertEqual(op.filePath, "/root/abcd/Sources/abcd/main.swift")
    XCTAssertEqual(op.fileContent, GeneratorParts.mainSwiftFileContent())
    XCTAssertEqual(op.errorString, "main swift")
  }

  func testCreateNewWriteOperationsWithRoot() {
    let operations = FileOperations.newProjectOperations(paths: Paths(rootDirectory: "/root/abcd"))
    let op = operations.operations.filter { $0.filePath.contains("root.swift") }.first! as! FileWriteOperation

    XCTAssertEqual(op.filePath, "/root/abcd/Sources/abcd/root.swift")
    XCTAssertEqual(op.fileContent, GeneratorParts.commandFile(forVarName: "root", commandName: "abcd"))
    XCTAssertEqual(op.errorString, "root swift")
  }

  func testCreateNewWriteOperationsWithSetup() {
    let operations = FileOperations.newProjectOperations(paths: Paths(rootDirectory: "/root/abcd"))
    let op = operations.operations.filter { $0.filePath.contains("setup.swift") }.first! as! FileWriteOperation

    XCTAssertEqual(op.filePath, "/root/abcd/Sources/abcd/setup.swift")
    XCTAssertEqual(op.fileContent, GeneratorParts.setupFileContent())
    XCTAssertEqual(op.errorString, "setup swift")
  }

  func testItWritesAFile() {
    MockFileType.fileWriteValue = ["/root/abc": true]
    GuakaCliConfig.file = MockFileType.self

    let op = FileWriteOperation(
      fileContent: GeneratorParts.mainSwiftFileContent(),
      filePath: "/root/abc",
      errorString: "main swift")

    try! op.perform()

    XCTAssertEqual(MockFileType.writtenFiles["/root/abc"], GeneratorParts.mainSwiftFileContent())
  }

  func testItThrowsItFailedToWriteFile() {
    MockFileType.fileWriteValue = ["/root/abc": false]
    GuakaCliConfig.file = MockFileType.self

    let op = FileWriteOperation(
      fileContent: GeneratorParts.mainSwiftFileContent(),
      filePath: "/root/abc",
      errorString: "main swift")

    do {
      try op.perform()
    } catch let e as GuakaError {
      XCTAssertEqual(e.error, "Cannot generate main swift file".f.Red)
    } catch {
      XCTFail()
    }
  }

  func testItWritesAllFilesForNewProject() {
    MockFileType.fileWriteValue = [
      "/root/abcd/Package.swift": true,
      "/root/abcd/Sources/abcd/main.swift": true,
      "/root/abcd/Sources/abcd/root.swift": true,
      "/root/abcd/Sources/abcd/setup.swift": true,
    ]
    GuakaCliConfig.file = MockFileType.self

    let ops = FileOperations.newProjectOperations(paths: Paths(rootDirectory: "/root/abcd"))
    try! ops.perform()

    XCTAssertEqual(MockFileType.writtenFiles.count, 4)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abcd/Package.swift"] == nil, false)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abcd/Sources/abcd/main.swift"] == nil, false)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abcd/Sources/abcd/root.swift"] == nil, false)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abcd/Sources/abcd/setup.swift"] == nil, false)
  }

  func testIfAnyFailsTheOperationFails() {
    MockFileType.fileWriteValue = [
      "/root/abcd/Package.swift": true,
      "/root/abcd/Sources/abcd/main.swift": true,
      "/root/abcd/Sources/abcd/root.swift": false,
      "/root/abcd/Sources/abcd/setup.swift": true,
    ]
    GuakaCliConfig.file = MockFileType.self

    let ops = FileOperations.newProjectOperations(paths: Paths(rootDirectory: "/root/abcd"))

    do {
      try ops.perform()
    } catch let e as GuakaError {
      XCTAssertEqual(e.error, "Cannot generate root swift file".f.Red)
    } catch {
      XCTFail()
    }

    XCTAssertEqual(MockFileType.writtenFiles.count, 3)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abcd/Package.swift"] == nil, false)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abcd/Sources/abcd/main.swift"] == nil, false)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abcd/Sources/abcd/root.swift"] == nil, false)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abcd/Sources/abcd/setup.swift"] == nil, true)
  }

  func testCanPerformUpdateOperations() {
    MockFileType.fileWriteValue = ["some/path": true]
    MockFileType.fileReadValue = ["some/path": "The File Content"]
    GuakaCliConfig.file = MockFileType.self

    let op = FileUpdateOperation(
      filePath: "some/path",
      operation: { x in return x + "abcd" },
      errorString: "some error")

    try! op.perform()

    XCTAssertEqual(MockFileType.writtenFiles["some/path"], "The File Contentabcd")
  }

  func testReturnExceptionIfCannotRead() {
    MockFileType.fileWriteValue = ["some/path": true]
    MockFileType.fileReadValue = [:]
    GuakaCliConfig.file = MockFileType.self

    let op = FileUpdateOperation(
      filePath: "some/path",
      operation: { x in return x + "abcd" },
      errorString: "some error")

    do {
      try op.perform()
    } catch let e as GuakaError {
      XCTAssertEqual(e.error, "Cannot read contents of file some/path".f.Red)
    } catch {
      XCTFail()
    }
  }

  func testItReturnExceptionIfCannotWriteUpdatedFile() {
    MockFileType.fileWriteValue = ["some/path": false]
    MockFileType.fileReadValue = ["some/path": "The File Content"]
    GuakaCliConfig.file = MockFileType.self

    let op = FileUpdateOperation(
      filePath: "some/path",
      operation: { x in return x + "abcd" },
      errorString: "some error")

    do {
      try op.perform()
    } catch let e as GuakaError {
      XCTAssertEqual(e.error, "Cannot generate some error file".f.Red)
    } catch {
      XCTFail()
    }
  }

  func testCreateAddCommandOperationsWithCommand() {
    let operations = FileOperations.addCommandOperations(
      paths: Paths(rootDirectory: "/root/abc"),
      commandName: "new", parent: nil)

    let op = operations.operations.filter { $0.filePath.contains("new.swift") }.first! as! FileWriteOperation

    XCTAssertEqual(op.filePath, "/root/abc/Sources/abc/new.swift")
    XCTAssertEqual(op.fileContent, GeneratorParts.commandFile(forVarName: "new", commandName: "new"))
    XCTAssertEqual(op.errorString, "new swift")
  }

  func testCreateAddCommandOperationsWithSetup() {
    let operations = FileOperations.addCommandOperations(
      paths: Paths(rootDirectory: "/root/abc"),
      commandName: "new", parent: nil)

    let op = operations.operations.filter { $0.filePath.contains("setup.swift") }.first! as! FileUpdateOperation

    XCTAssertEqual(op.filePath, "/root/abc/Sources/abc/setup.swift")
    XCTAssertEqual(op.errorString, "setup swift")
  }

  func testItUpdatesTheSetupFileWithNoParent() {
    MockFileType.fileWriteValue = [
      "/root/abc/Sources/abc/setup.swift": true,
      "/root/abc/Sources/abc/new.swift": true
    ]
    MockFileType.fileReadValue = [
      "/root/abc/Sources/abc/setup.swift": GeneratorParts.setupFileContent()
    ]
    GuakaCliConfig.file = MockFileType.self

    let operations = FileOperations.addCommandOperations(
      paths: Paths(rootDirectory: "/root/abc"),
      commandName: "new", parent: nil)

    try! operations.perform()

    var updatedSetup = GeneratorParts.setupFileContent()
    updatedSetup = try! GeneratorParts.updateSetupFile(
      withContent: updatedSetup,
      byAddingCommand: "newCommand",
      withParent: nil)

    XCTAssertEqual(MockFileType.writtenFiles["/root/abc/Sources/abc/setup.swift"], updatedSetup)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abc/Sources/abc/new.swift"], GeneratorParts.commandFile(forVarName: "new", commandName: "new"))
  }

  func testItUpdatesTheSetupFileWithParent() {
    MockFileType.fileWriteValue = [
      "/root/abc/Sources/abc/setup.swift": true,
      "/root/abc/Sources/abc/new.swift": true
    ]
    MockFileType.fileReadValue = [
      "/root/abc/Sources/abc/setup.swift": GeneratorParts.setupFileContent()
    ]
    GuakaCliConfig.file = MockFileType.self

    let operations = FileOperations.addCommandOperations(
      paths: Paths(rootDirectory: "/root/abc"),
      commandName: "new", parent: "something")

    try! operations.perform()

    var updatedSetup = GeneratorParts.setupFileContent()
    updatedSetup = try! GeneratorParts.updateSetupFile(
      withContent: updatedSetup,
      byAddingCommand: "newCommand",
      withParent: "something")

    XCTAssertEqual(MockFileType.writtenFiles["/root/abc/Sources/abc/setup.swift"], updatedSetup)
    XCTAssertEqual(MockFileType.writtenFiles["/root/abc/Sources/abc/new.swift"], GeneratorParts.commandFile(forVarName: "new", commandName: "new"))
  }

  func testItFailsToUpdateIfCannotReadSetupFileContent() {
    MockFileType.fileWriteValue = [
      "/root/abc/Sources/abc/setup.swift": true,
      "/root/abc/Sources/abc/new.swift": true
    ]
    MockFileType.fileReadValue = [
      "/root/abc/Sources/abc/setup.swift": "asasds"
    ]
    GuakaCliConfig.file = MockFileType.self

    let operations = FileOperations.addCommandOperations(
      paths: Paths(rootDirectory: "/root/abc"),
      commandName: "new", parent: "something")
    
    do {
      try operations.perform()
    } catch GuakaError.setupFileAltered {
    } catch {
      XCTFail()
    }

  }

  static let allTests = [
    ("testCreateNewWriteOperationsWithPackage", testCreateNewWriteOperationsWithPackage),
    ("testCreateNewWriteOperationsWithMain", testCreateNewWriteOperationsWithMain),
    ("testCreateNewWriteOperationsWithRoot", testCreateNewWriteOperationsWithRoot),
    ("testCreateNewWriteOperationsWithSetup", testCreateNewWriteOperationsWithSetup),
    ("testItWritesAFile", testItWritesAFile),
    ("testItThrowsItFailedToWriteFile", testItThrowsItFailedToWriteFile),
    ("testItWritesAllFilesForNewProject", testItWritesAllFilesForNewProject),
    ("testIfAnyFailsTheOperationFails", testIfAnyFailsTheOperationFails),
    ("testCanPerformUpdateOperations", testCanPerformUpdateOperations),
    ("testReturnExceptionIfCannotRead", testReturnExceptionIfCannotRead),
    ("testItReturnExceptionIfCannotWriteUpdatedFile", testItReturnExceptionIfCannotWriteUpdatedFile),
    ("testCreateAddCommandOperationsWithCommand", testCreateAddCommandOperationsWithCommand),
    ("testCreateAddCommandOperationsWithSetup", testCreateAddCommandOperationsWithSetup),
    ("testItUpdatesTheSetupFileWithNoParent", testItUpdatesTheSetupFileWithNoParent),
    ("testItUpdatesTheSetupFileWithParent", testItUpdatesTheSetupFileWithParent),
    ("testItFailsToUpdateIfCannotReadSetupFileContent", testItFailsToUpdateIfCannotReadSetupFileContent),
  ]
}
