// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

final class EasyListsStorage {
    static var shared: EasyListsStorage = EasyListsStorage()
    
    func saveResponseToFile(filename: EasyListsName, response: URLResponse, data: Data, completion: @escaping (URL?, Error?) -> Void) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil, URLError(.cannotCreateFile))
            return
        }
        
        var fileURL = documentsURL.appendingPathComponent(filename.rawValue)
        fileURL.appendPathExtension("txt")
        
        do {
            guard fileManager.fileExists(atPath: fileURL.path) else {
                // Create new file here
                fileManager.createFile(atPath: fileURL.path,
                                       contents: data, attributes: nil)
                completion(fileURL, nil)
                return
            }
            try data.write(to: fileURL, options: [.atomicWrite])

            
            print("readFileFromDocuments(filename: filename): \(readFileFromDocuments(filename: filename))")
            completion(fileURL, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func readFileFromDocuments(filename: EasyListsName) -> URL? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        var fileURL = documentsURL.appendingPathComponent(filename.rawValue)
        fileURL.appendPathExtension("txt")
        if self.isFileWithNameExist(filename: filename.rawValue) {
            return fileURL
        } else {
            return nil
        }
    }
    
    private func isFileWithNameExist(filename: String) -> Bool {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        var fileURL = documentsURL.appendingPathComponent(filename)
        fileURL.appendPathExtension("txt")
        if fileManager.fileExists(atPath: fileURL.path) {
            return true
        }
        return false
    }
    
    func deleteFileFromDocuments(filename: EasyListsName, completion: @escaping (Error?) -> Void) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(URLError(.cannotCreateFile))
            return
        }
        
        var fileURL = documentsURL.appendingPathComponent(filename.rawValue)
        fileURL.appendPathExtension("txt")
        
        do {
            try fileManager.removeItem(at: fileURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func lastModifiedSince1970(filenames: [EasyListsName]) -> Date? {
        do {
            let fileManager = FileManager.default
            var dates: [Date] = []
            for filename in EasyListsName.names {
                guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
                var fileURL = documentsURL.appendingPathComponent(filename.rawValue)
                fileURL.appendPathExtension("txt")
                let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                guard let date = attr[FileAttributeKey.modificationDate] as? Date else { return nil }
                dates.append(date)
            }
            
            return dates.min()
        } catch {
            return nil
        }
    }
}
/*
 file:///var/mobile/Containers/Data/Application/04B27F62-727C-41A1-9D03-B060C8A06DE0/Documents/easy-list.txt
 
 file:///var/mobile/Containers/Data/Application/04B27F62-727C-41A1-9D03-B060C8A06DE0/Documents/easy-list.txt
 */
