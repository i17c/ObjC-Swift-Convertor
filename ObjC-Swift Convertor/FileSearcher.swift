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
		if filePath != nil {
			if fileManager.fileExistsAtPath(filePath!) {
				return true
			}
		}
		return false
	}

	// Setting the root path for directory, check file existance and readability
	public var filePath:String? = nil {
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
		self.filePath = filePath
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

	/********************
	* Internal
	*********************/

	// Define this method as internal for testing purpose
	internal func findObjCFiles() -> [String]? {
		return searchObjCFilesInPath(filePath)
	}

	/********************
	* Private
	*********************/

	// Assume file exists
	// Returns a array with all the names of files in it.
	private func searchObjCFilesInPath(path:String!) -> [String]? {
		if path != nil {
			var res:[String] = [String]()
			var isDirectory:ObjCBool = ObjCBool(0)
			if fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) {
				// If the given root file is a path, then walk through it.
				if isDirectory {
					var potentialErrror:NSError?

					if let contents = fileManager.contentsOfDirectoryAtPath(path, error: &potentialErrror) {
						for file in contents {
							let filePath:NSString = file as NSString
							var currentFileIsDir:ObjCBool = ObjCBool(0)
							fileManager.fileExistsAtPath(filePath, isDirectory: &currentFileIsDir)
							if currentFileIsDir {
								let temp:[String]? = searchObjCFilesInPath(filePath)
								if temp != nil {
									res += temp!
								}
							} else {
								var pathExtension:String? = NSURL(fileURLWithPath: filePath).pathExtension
								if pathExtension == "m" || pathExtension == "h" {
									res.append(path + filePath)
								}
							}
						}
					} else if let error = potentialErrror {
						println(error.description)
					}

				} else {
					var pathExtension:String? = NSURL(fileURLWithPath: path).pathExtension
					if pathExtension == ".m" || pathExtension == ".h" {
						res.append(path)
					}
				}
				return res
			}
		}
		return nil
	}
}

