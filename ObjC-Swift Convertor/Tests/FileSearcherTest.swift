//
//  FileSearcherTest.swift
//  ObjC-Swift Convertor
//
//  Created by Shuyang Sun on 9/2/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

import Cocoa
import XCTest

class FileSearcherTest: XCTestCase {
	var fileSearcher:FileSearcher = FileSearcher()
	var foundFileArr:[String]?
	var foundFilePairs:[(header:String?, implementation:String?)]?

    override func setUp() {
        super.setUp()
		fileSearcher.rootFilePath = "/Users/shuyangsun/Developer/iOS Projects/2048 Facebook/2048 Friends/"
    }
    
    override func tearDown() {

        super.tearDown()
    }

	func testFindObjCFiles_Performence() {
		self.measureBlock  {
			self.foundFileArr = self.fileSearcher.findObjCFiles()
		}
	}

	func testFindPairedObjCFiles_Performence() {
		self.measureBlock {
			self.foundFilePairs = self.fileSearcher.findPairedObjCFiles()
		}
	}

	func testFileExists() {
		var fileManager:NSFileManager = NSFileManager.defaultManager()
		foundFileArr = fileSearcher.findObjCFiles()
		if foundFileArr != nil {
			for filePath:String in foundFileArr! {
				var isDir:ObjCBool = ObjCBool(0)
				XCTAssertTrue(fileManager.fileExistsAtPath(filePath, isDirectory: &isDir), "File \"\(filePath)\" does not exist.")
				XCTAssertFalse(isDir, "File is a directory.")
			}
		}
	}

	func testFindObjCFiles_DidFindFiles() {
		foundFileArr = fileSearcher.findObjCFiles()
		let foundFileArrDoesNotExist:Bool = (foundFileArr == nil)
		XCTAssertFalse(foundFileArrDoesNotExist, "foundFileArr is nil.")
		if foundFileArr != nil {
			XCTAssertNotEqual(foundFileArr!.count, 0, "Found no ObjC file in \"\(fileSearcher.rootFilePath).\"")
		}
	}

	func testFoundFileExtension() {
		if foundFileArr != nil {
			for filePath:String in foundFileArr! {
				var path:NSString = filePath as NSString
				XCTAssertTrue(path.length >= 2, "File name length less than 2.");
				var fileExtension:NSString = path.substringFromIndex(path.length - 2)
				XCTAssertTrue(fileExtension == ".h" || fileExtension == ".m", "File extension wrong.")
			}
		}
	}

	func testFindPairedObjCFiles() {
		foundFilePairs = fileSearcher.findPairedObjCFiles()
		if let pairs = foundFilePairs {
			for (header, implementation) in pairs {
				if let h = header {
					if let imp = implementation {
						let lastPathComp_imp = imp.lastPathComponent
						let lastPathCompNSString_imp = lastPathComp_imp as NSString
						let fileName_imp = lastPathCompNSString_imp.substringToIndex(lastPathCompNSString_imp.length - 2)

						let lastPathComp_header = h.lastPathComponent
						let lastPathCompNSString_header = lastPathComp_header as NSString
						let fileName_header = lastPathCompNSString_header.substringToIndex(lastPathCompNSString_header.length - 2)

						XCTAssertEqual(fileName_header, fileName_imp)
					}
				} else if let imp = implementation {
					if let h = header {
							let lastPathComp_imp = imp.lastPathComponent
							let lastPathCompNSString_imp = lastPathComp_imp as NSString
							let fileName_imp = lastPathCompNSString_imp.substringToIndex(lastPathCompNSString_imp.length - 2)

							let lastPathComp_header = h.lastPathComponent
							let lastPathCompNSString_header = lastPathComp_header as NSString
							let fileName_header = lastPathCompNSString_header.substringToIndex(lastPathCompNSString_header.length - 2)

							XCTAssertEqual(fileName_header, fileName_imp)
					}
				}
			}
		}
	}
	
}
