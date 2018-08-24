import XCTest
@testable import GuakaClILibTests

XCTMain([
  testCase(DirectoryStateTests.allTests),
  testCase(DirectoryUtilitiesTests.allTests),
  testCase(FileWriteOperationTests.allTests),
  testCase(GeneratorPartsTests.allTests),
  testCase(PathsTests.allTests),
])
