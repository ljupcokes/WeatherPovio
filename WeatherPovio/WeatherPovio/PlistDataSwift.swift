//
//  DataWeatherPlist.swift
//  WeatherPovio
//
//  Created by Ljupco Gorgiev on 4/2/16.
//  Copyright © 2016 Developers. All rights reserved.
//

import Foundation

struct PlistDataSwift {
    
    enum PlistError: ErrorType {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name:String
    
    var sourcePath:String? {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist") else { return .None }
        return path
    }
    
    var destPath:String? {
        guard sourcePath != .None else { return .None }
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (dir as NSString).stringByAppendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {
        
        self.name = name
        let fileManager = NSFileManager.defaultManager()
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExistsAtPath(source) else { return nil }
        
        if !fileManager.fileExistsAtPath(destination) {
            do {
                try fileManager.copyItemAtPath(source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    
    func getValuesInPlistFile() -> NSDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    
    func getMutableArrayPlistFile() -> NSMutableArray?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let array = NSMutableArray(contentsOfFile: destPath!) else { return .None }
            return array
        } else {
            return .None
        }
    }
    
    func addValuesToPlistFile(dictionary:NSDictionary) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            let tmpArray  = self.getMutableArrayPlistFile()!
            tmpArray.addObject(dictionary)
            if !tmpArray.writeToFile(destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
    func updateValuesToPlistFile(dictionary:NSDictionary) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            let tmpArray  = self.getMutableArrayPlistFile()!
            for (index, tmpDictionary) in tmpArray.enumerate() {
                if tmpDictionary.valueForKey(kCityId)?.integerValue == dictionary.valueForKey(kCityId)?.integerValue {
                    tmpArray.replaceObjectAtIndex(index, withObject:dictionary)
                    break
                }
            }
            if !tmpArray.writeToFile(destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
    func removeDataFromPlistFile(dictionary:NSDictionary) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            let tmpArray  = self.getMutableArrayPlistFile()!
            tmpArray.removeObject(dictionary)
            if !tmpArray.writeToFile(destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
    func addArrayToPlistFile(array:NSMutableArray) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            if !array.writeToFile(destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
}