//
//  DirectoryUtilitiesTests.swift
//  guaka-cli
//
//  Created by Omar Abdelhafith on 27/11/2016.
//
//

import XCTest
@testable import GuakaClILib

class DirectoryUtilitiesTests: XCTestCase {

  override func setUp() {
    super.setUp()
    MockDirectoryType.clear()
  }

  func testReturnCurrentFolderIfNameIsNotProvidedExample() {
    MockDirectoryType.currentDirectory = "ABCD"

    GuakaCliConfig.dir = MockDirectoryType.self

    let s = try! DirectoryUtilities.currentDirectory(forName: nil)
    XCTAssertEqual(s, "ABCD")
  }

  func testReturnCurrentPathPlusRelativePathExample() {
    MockDirectoryType.currentDirectory = "/root"
    MockDirectoryType.pathsValidationValue = ["/root/some/path": true]
    MockDirectoryType.pathsEmptyValue = ["/root/some/path": true]

    GuakaCliConfig.dir = MockDirectoryType.self

    let s = try! DirectoryUtilities.currentDirectory(forName: "some/path")
    XCTAssertEqual(s, "/root/some/path")
  }

  func testReturnCurrentPathPlusNamePathExample() {
    MockDirectoryType.currentDirectory = "/root"
    MockDirectoryType.pathsValidationValue = ["/root/path": true]
    MockDirectoryType.pathsEmptyValue = ["/root/path": true]

    GuakaCliConfig.dir = MockDirectoryType.self

    let s = try! DirectoryUtilities.currentDirectory(forName: "path")
    XCTAssertEqual(s, "/root/path")
  }

  func testReturnAbsolutePathExample() {
    MockDirectoryType.currentDirectory = "/root"
    MockDirectoryType.pathsValidationValue = ["/some/root/path": true]
    MockDirectoryType.pathsEmptyValue = ["/some/root/path": true]

    GuakaCliConfig.dir = MockDirectoryType.self

    let s = try! DirectoryUtilities.currentDirectory(forName: "/some/root/path")
    XCTAssertEqual(s, "/some/root/path")
  }

  func testReturnExceptionIfPathIsNotValud() {
    MockDirectoryType.currentDirectory = "/root"
    MockDirectoryType.pathsValidationValue = ["/some/root/path": false]

    GuakaCliConfig.dir = MockDirectoryType.self

    do {
      _ = try DirectoryUtilities.currentDirectory(forName: "/some/root/path")
    } catch GuakaError.wrongDirectoryGiven(let path) {
      XCTAssertEqual(path, "/some/root/path")
    } catch {
      XCTFail()
    }
  }

  func testRetunrErrorIfPathIsFolderAndNonEmpty() {
    MockDirectoryType.currentDirectory = "/root"
    MockDirectoryType.pathsValidationValue = ["/some/root/path": true]
    MockDirectoryType.pathsEmptyValue = ["/some/root/path": false]

    GuakaCliConfig.dir = MockDirectoryType.self

    do {
      _ = try DirectoryUtilities.currentDirectory(forName: "/some/root/path")
    } catch GuakaError.wrongDirectoryGiven(let path) {
      XCTAssertEqual(path, "/some/root/path")
    } catch {
      XCTFail()
    }
  }

  func testReturnErrorIfPathDoesNotExist() {
    MockDirectoryType.currentDirectory = "/root"

    GuakaCliConfig.dir = MockDirectoryType.self

    do {
      _ = try DirectoryUtilities.currentDirectory(forName: "/some/root/path")
    } catch GuakaError.wrongDirectoryGiven(let path) {
      XCTAssertEqual(path, "/some/root/path")
    } catch {
      XCTFail()
    }
    
  }

  func testThrowsFolderIfFolderHasContent() {
    MockDirectoryType.currentDirectory = "/root"

    GuakaCliConfig.dir = MockDirectoryType.self

    let paths = Paths(rootDirectory: "/root")
    do {
      try DirectoryUtilities.createDirectoryStructure(paths: paths,
                                                      directoryState: .hasContent)
    } catch GuakaError.triedToCreateProjectInNonEmptyDirectory(let path) {
      XCTAssertEqual(path, "/root")
    } catch {
      XCTFail()
    }
    
  }

  func testTriesToCreateRootFolderIfNonExisting() {
    MockDirectoryType.pathsCreationValue = [
      "/root": true,
      "/root/Sources/root": true,
    ]

    GuakaCliConfig.dir = MockDirectoryType.self

    let paths = Paths(rootDirectory: "/root")

    try! DirectoryUtilities.createDirectoryStructure(paths: paths,
                                                    directoryState: .nonExisting)
    let val = MockDirectoryType.pathsCreated.contains("/root")
    XCTAssertEqual(val, true)
  }

  func testTriesToCreateSourcesFolderIfNonExisting() {
    MockDirectoryType.pathsCreationValue = [
      "/root": true,
      "/root/Sources/root": true,
    ]

    GuakaCliConfig.dir = MockDirectoryType.self

    let paths = Paths(rootDirectory: "/root")

    try! DirectoryUtilities.createDirectoryStructure(paths: paths,
                                                     directoryState: .nonExisting)
    let val = MockDirectoryType.pathsCreated.contains("/root/Sources/root")
    XCTAssertEqual(val, true)
  }

  func testThrowsErrorIfCreateRootFailed() {
    MockDirectoryType.pathsCreationValue = [
      "/root": false,
      "/root/Sources": true,
    ]

    GuakaCliConfig.dir = MockDirectoryType.self

    let paths = Paths(rootDirectory: "/root")

    do {
      try DirectoryUtilities.createDirectoryStructure(paths: paths,
                                                      directoryState: .nonExisting)
    } catch GuakaError.failedCreatingFolder(let path) {
      XCTAssertEqual(path, "/root")
    } catch {
      XCTFail()
    }
  }

  func testThrowsErrorIfCreateSourcesFailed() {
    MockDirectoryType.pathsCreationValue = [
      "/root": true,
      "/root/Sources": false,
      "/root/Sources/root": false,
    ]

    GuakaCliConfig.dir = MockDirectoryType.self

    let paths = Paths(rootDirectory: "/root")

    do {
      try DirectoryUtilities.createDirectoryStructure(paths: paths,
                                                      directoryState: .nonExisting)
    } catch GuakaError.failedCreatingFolder(let path) {
      XCTAssertEqual(path, "/root/Sources/root")
    } catch {
      XCTFail()
    }
  }

  func testFullSuccessfullRun() {
    MockDirectoryType.currentDirectory = "/root"
    MockDirectoryType.pathsExistanceValue = ["/root": true]
    MockDirectoryType.pathsEmptyValue = ["/root": true]
    MockDirectoryType.pathsCreationValue = ["/root": true, "/root/Sources/root": true]

    GuakaCliConfig.dir = MockDirectoryType.self

    try! DirectoryUtilities.createDirectoryStructure(forName: nil)

  }

  func testReturnThePathsForAFolder() {
    MockDirectoryType.currentDirectory = "/root"
    MockDirectoryType.pathsValidationValue = ["/some/root/path": true]
    MockDirectoryType.pathsEmptyValue = ["/some/root/path": true]

    GuakaCliConfig.dir = MockDirectoryType.self

    let s = try! DirectoryUtilities.paths(forName: "/some/root/path")
    XCTAssertEqual(s.rootDirectory, "/some/root/path")
  }

  static let allTests = [
    ("testReturnCurrentFolderIfNameIsNotProvidedExample", testReturnCurrentFolderIfNameIsNotProvidedExample),
    ("testReturnCurrentPathPlusRelativePathExample", testReturnCurrentPathPlusRelativePathExample),
    ("testReturnCurrentPathPlusNamePathExample", testReturnCurrentPathPlusNamePathExample),
    ("testReturnAbsolutePathExample", testReturnAbsolutePathExample),
    ("testReturnExceptionIfPathIsNotValud", testReturnExceptionIfPathIsNotValud),
    ("testRetunrErrorIfPathIsFolderAndNonEmpty", testRetunrErrorIfPathIsFolderAndNonEmpty),
    ("testReturnErrorIfPathDoesNotExist", testReturnErrorIfPathDoesNotExist),
    ("testThrowsFolderIfFolderHasContent", testThrowsFolderIfFolderHasContent),
    ("testTriesToCreateRootFolderIfNonExisting", testTriesToCreateRootFolderIfNonExisting),
    ("testTriesToCreateSourcesFolderIfNonExisting", testTriesToCreateSourcesFolderIfNonExisting),
    ("testThrowsErrorIfCreateRootFailed", testThrowsErrorIfCreateRootFailed),
    ("testThrowsErrorIfCreateSourcesFailed", testThrowsErrorIfCreateSourcesFailed),
    ("testFullSuccessfullRun", testFullSuccessfullRun),
    ("testReturnThePathsForAFolder", testReturnThePathsForAFolder),
  ]
}
