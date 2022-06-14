//
//  FireStorage.swift
//  Chat Messenger
//
//  Created by manukant tyagi on 12/06/22.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()
class FileStorage{
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void){
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        
        let imageData = image.jpegData(compressionQuality: 0.6)
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!, metadata: nil, completion: { metadata, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil{
                print("error uploading image \(error?.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url else{
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        task.observe(StorageTaskStatus.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void){
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        if fileExistAtPath(path: imageFileName){
            //get it locally
            if let contentOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(fileName: imageFileName)){
                completion(contentOfFile)
            }else{
                print("couldn't convert local image")
                completion(UIImage(named: "avatar"))
            }
        } else {
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil{
                        // save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                    }else{
                        print("no doucument in database")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        
                    }
                }
            }
        }
    }
    
    //MARK: Save Locally
    class func saveFileLocally(fileData: NSData, fileName: String){
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true )
    }
}

// Helpers
func fileInDocumentDirectory(fileName: String) -> String{
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistAtPath(path: String) -> Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentDirectory(fileName: path))
}
