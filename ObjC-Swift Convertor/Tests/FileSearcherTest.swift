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

    override func setUp() {
        super.setUp()
		fileSearcher.filePath = "ObjC-Swift Convertor Test/Test Files/2048 Facebook"
    }
    
    override func tearDown() {

        super.tearDown()
    }

	func testFindObjCFiles_Performence() {
		self.measureBlock  {
			self.foundFileArr = self.fileSearcher.findObjCFiles()
		}
	}

	func testFileExists() {
		var fileManager:NSFileManager = NSFileManager.defaultManager()
		if foundFileArr != nil {
			for filePath:String in foundFileArr! {
				var isDir:ObjCBool = ObjCBool(0)
				XCTAssertTrue(fileManager.fileExistsAtPath(filePath, isDirectory: &isDir), "File does not exist.")
				XCTAssertFalse(isDir, "File is a directory.")
			}
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
	
}
