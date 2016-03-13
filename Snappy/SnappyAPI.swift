//
//  SnappyAPI.swift
//  API
//
//  Created by Lukasz Mroz on 12.03.2016.
//  Copyright © 2016 DroidsOnRoids. All rights reserved.
//

import Alamofire
import AlamofireImage

/// Struct containing all constants that are needed for
/// API Requests, like URLS, parameter names etc.
struct SnapchatAPIConstants {
    
    static let userId = 1;
    
    struct URL {
        private static let base = "https://serene-escarpment-58247.herokuapp.com"
        private static let imagesEndpoint = {
            return base + "/images"
        }()
        
        static let uploadImage = {
            return imagesEndpoint + "/upload"
        }()
        static let getImages = {
            return imagesEndpoint + "/get"
        }()
        static func getImages(forUser userId: Int) -> String {
            return imagesEndpoint + "/get/\(userId)"
        }
    }
    
    struct Method {
        static let getImages = Alamofire.Method.GET
        static let uploadImage = Alamofire.Method.POST
        static let downloadImage = Alamofire.Method.GET
    }
    
    struct Error {
        static func alamofireResultError(withMessage message: String) -> Result<AnyObject, NSError> {
            let error = NSError(domain: "com.alamofire",
                code: -100,
                userInfo: [NSLocalizedDescriptionKey: message])
            return Result<AnyObject, NSError>.Failure(error)
        }
        
        static let alamofireEncodingError = {
            return Error.alamofireResultError(withMessage: "There was a problem with encoding.")
        }()
        
        static let alamofireUnknownError = {
            return Error.alamofireResultError(withMessage: "There was a problem with API.")
        }()
    }
    
    struct Parameters {
        static let imageFile = "file"
        static let toUserID = "to_userId"
        static let fromUserID = "from_userId"
    }
}

/// Main struct to SnapchatAPI with uploading/downloading
struct SnapchatAPI {
    
    typealias APIResult = Result<AnyObject, NSError>
    typealias APICompletionHandler = APIResult -> Void
    typealias APIImageCompletionHandler = Result<UIImage, NSError> -> Void
    typealias APIMultipartFormData = MultipartFormData -> Void
    
    /// Uploads image and will be send to everyone
    static func upload(image image: UIImage, multipartFormData: APIMultipartFormData? = nil, completion: APICompletionHandler? = nil) {
        // We transform our image to data that we can send on server.
        // Here we have 80% compression quality, which is 0.8 by default,
        // you can change it by specifying parameter in toData() function.
        // We use guard to be sure that our image can be represented as
        // NSData.
        guard let imageData = image.toData() else { return }
        
        // Using Alamofire we will upload the data on a server and return
        // response with completion block
        Alamofire.upload(SnapchatAPIConstants.Method.uploadImage,
            SnapchatAPIConstants.URL.uploadImage,
            multipartFormData: { multipartData in
                multipartData.appendBodyPart(data: imageData,
                    name: SnapchatAPIConstants.Parameters.imageFile,
                    fileName: "file.jpg",
                    mimeType: "image/jpeg"
                )
                multipartData.appendBodyPart(
                    data: "\(SnapchatAPIConstants.userId)".dataUsingEncoding(NSUTF8StringEncoding)!,
                    name: SnapchatAPIConstants.Parameters.fromUserID
                )
                multipartFormData?(multipartData)
            }) { result in
                switch result {
                case .Success(let upload, _, _):
                    upload.responseData { response in
                        switch response.result {
                        case .Success(let data):
                            print("Success: \(String(data: data, encoding: NSUTF8StringEncoding))")
                        case .Failure(let error):
                            print("Error: \(error)")
                        }
                    }
                    upload.responseJSON { response in
                        var result: APIResult!
                        if let statusCode = response.response?.statusCode where 400...510 ~= statusCode {
                            if let message = response.result.value?["error"] as? String {
                                result = SnapchatAPIConstants.Error.alamofireResultError(withMessage: message)
                            } else {
                                result = SnapchatAPIConstants.Error.alamofireUnknownError
                            }
                        } else {
                            result = response.result
                        }
                        
                        completion?(result)
                    }
                case .Failure(_):
                    completion?(SnapchatAPIConstants.Error.alamofireEncodingError)
                }
        }
    }
    
    /// Uploads image, but only to specific user
    static func upload(image image: UIImage, toUser userId: Int, completion: APICompletionHandler) {
        let multipartFormData: APIMultipartFormData = { multipartData in
            multipartData.appendBodyPart(data: "\(userId)".dataUsingEncoding(NSUTF8StringEncoding)!,
                name: SnapchatAPIConstants.Parameters.toUserID
            )
        }
        upload(image: image, multipartFormData: multipartFormData, completion: completion)
    }
    
    /// Fetch images that were sent to everyone
    static func getImages(parameters parameters: [String: AnyObject]? = nil, completion: APICompletionHandler) {
        Alamofire
            .request(SnapchatAPIConstants.Method.getImages, SnapchatAPIConstants.URL.getImages, parameters: parameters)
            .responseJSON { response in
                completion(response.result)
        }
    }
    
    /// Fetch images that were sent to you OR to everyone
    static func getImages(forUser userId: Int, completion: APICompletionHandler) {
        getImages(parameters: [SnapchatAPIConstants.Parameters.toUserID: userId], completion: completion)
    }
    
    /// Download image with url
    static func downloadImage(url: String, completionHandler: APIImageCompletionHandler) {
        Alamofire
            .request(SnapchatAPIConstants.Method.downloadImage, url)
            .responseImage { response in
                completionHandler(response.result)
        }
    }
    
}

extension UIImage {
    func toData(withCompressQuality compressQuality: CGFloat = 0.8) -> NSData? {
        return UIImageJPEGRepresentation(self, compressQuality)
    }
}