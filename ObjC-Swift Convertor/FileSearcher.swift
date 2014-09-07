//
//  FileManger.swift
//  ObjC-Swift Convertor
//
//  Created by Shuyang Sun on 9/1/14.
//  Copyright (c) 2014 Shuyang Sun. All rights reserved.
//

import Foundation

public class FileSearcher {

	/**********************
	* Properties
	**********************/

	// This is the FileManger that is gonna be used in this class
	private lazy var fileManager:NSFileManager = NSFileManager.defaultManager()

	// Computed property to check if the file exists
	public var fileExists:Bool {
		if rootFilePath != nil {
			if fileManager.fileExistsAtPath(rootFilePath!) {
				return true
			}
		}
		return false
	}

	// Setting the root path for directory, check file existance and readability
	public var rootFilePath:String? = nil {
		willSet {
			if newValue != nil {
				if !fileExists {
					println("ERROR: File does not exist.")
				} else if !fileManager.isReadableFileAtPath(newValue!) {
					println("ERROR: File not readable.")
				}
			}
		}
	}

	/**********************
	 * Initializers
	 **********************/

	init(filePath:String?) {
		self.rootFilePath = filePath
	}

	convenience init() {
		self.init(filePath: nil)
	}

	/********************
	 * Methods
	 *********************/

	/********************
	* Public
	*********************/

	public func findPairedObjCFiles() -> [(header:String?, implementation:String?)]? {
		var arr = findObjCFiles()
		return pairFilesFromArray(arr)
	}

	public func printFilePairs() {
		var pairedObjCFiles = self.findPairedObjCFiles()
		for (header, imp) in pairedObjCFiles! {
			print("[")
			if let h = header {
				print(h.lastPathComponent)
			}
			if let i = imp {
				print(", " + i.lastPathComponent)
			}
			println("]")
		}
	}

	/********************
	* Internal
	*********************/

	internal func findObjCFiles() -> [String]? {
		let arr:[String]? = searchObjCFilesInPath(rootFilePath)
		return arr
	}

	/********************
	* Private
	*********************/

	private func pairFilesFromArray(array:[String]?) -> [(header:String?, implementation:String?)]? {
		var res:[(header:String?, implementation:String?)]? = []

		// If there is an array passed in, do something. Otherwise return nil
		if var arr = array {
			for var i:Int = 0; i < countElements(arr); ++i {
				let path:String = arr[i]
				var tempPair:(header:String?, implementation:String?) = (nil, nil)
				let fName:NSString = path.lastPathComponent
				let fileNameWithoutExtension:String = fName.substringToIndex(fName.length - 2)
				let pathExtension:String = path.pathExtension
				if pathExtension == "h" {
					tempPair.header = path
				} else if pathExtension == "m" {
					tempPair.implementation = path
				}
				arr.removeAtIndex(i)
				let potentialMatches:[String]? = arr.filter {
					let str = $0 as NSString
					let theOtherFileName:NSString = str.lastPathComponent
					return theOtherFileName.substringToIndex(theOtherFileName.length - 2) == fileNameWithoutExtension
				}
				if potentialMatches != nil && countElements(potentialMatches!) == 1 {
					if pathExtension == "h" {
						tempPair.implementation = potentialMatches!.first
					} else if pathExtension == "m" {
						tempPair.header = potentialMatches!.first
					}
				}

				// Todo: Doing this instead of .append() is because a Swift bug
				let tempArr:[(header:String?, implementation:String?)] = [tempPair]
				res! += tempArr
			}
		}
		return res
	}

	// Assume file exists
	// Returns a array with all the names of files in it.
	private func searchObjCFilesInPath(filePath:String!) -> [String]? {
		if var path = filePath {
			var res:[String]? = [String]()
			var isDirectory:ObjCBool = ObjCBool(0)
			if fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) {
				// If the given root file is a path, then walk through it.
				if isDirectory {
					var pathNSStr:NSString = path as NSString
					if pathNSStr.substringFromIndex(pathNSStr.length - 1) != "/" {
						path += "/"
					}
					var potentialErrror:NSError?

					if let contents = fileManager.contentsOfDirectoryAtPath(path, error: &potentialErrror) {
						for file in contents {
							var currentFileName:String = file as String
							currentFileName = path + currentFileName
							var currentFileIsDir:ObjCBool = ObjCBool(0)
							if fileManager.fileExistsAtPath(currentFileName, isDirectory: &currentFileIsDir) {
								if currentFileIsDir {
									/* let temp:[String]? = searchObjCFilesInPath(currentFileName)
									if temp != nil && countElements(temp!) != 0{
										res! += temp!
									} */
								} else {
									var pathExtension:String? = NSURL(fileURLWithPath: currentFileName).pathExtension
									if pathExtension == "m" || pathExtension == "h" {
										res!.append(currentFileName)
									}
								}
							}
						}
					} else if let error = potentialErrror {
						println(error.description)
					}

				} else {
					var pathExtension:String? = NSURL(fileURLWithPath: path).pathExtension
					if pathExtension == "m" || pathExtension == "h" {
						res!.append(path)
					}
				}
				return res
			}
		}
		return nil
	}
}

