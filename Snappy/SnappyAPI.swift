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
        fileprivate static let base = "https://snappytestapp.herokuapp.com"
        fileprivate static let imagesEndpoint = {
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
        static let removeImage = {
            return imagesEndpoint + "/remove"
        }()
    }
    
    struct Method {
        static let getImages: HTTPMethod = .get
        static let uploadImage: HTTPMethod = .post
        static let downloadImage: HTTPMethod = .get
        static let removeImage: HTTPMethod = .post
    }
    
    struct Error {
        static func alamofireResultError(withMessage message: String) -> Result<Any> {
            let error = NSError(domain: "com.alamofire",
                                code: -100,
                                userInfo: [NSLocalizedDescriptionKey: message])
            return Result.failure(error)
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
        static let fileName = "file_name"
    }
}

/// Main struct to SnapchatAPI with uploading/downloading
struct SnapchatAPI {
    
    typealias APIResult = Result<Any>
    typealias APICompletionHandler = (APIResult) -> Void
    typealias APIImageCompletionHandler = (Result<UIImage>) -> Void
    typealias APIMultipartFormData = (MultipartFormData) -> Void
    /// Uploads image and will be send to everyone
    
    static func upload(image: UIImage, multipartFormData: APIMultipartFormData? = nil,  completion: @escaping APICompletionHandler ) {
        // We transform our image to data that we can send on server.
        // Here we have 80% compression quality, which is 0.8 by default,
        // you can change it by specifying parameter in toData() function.
        // We use guard to be sure that our image can be represented as
        // Data.
        guard let imageData = image.toData() else { return }
        
        let multipartDataClosure = SnapchatAPI.prepareMultiPartDataClosure(image: imageData)
        let responseJSONClosure = SnapchatAPI.preapreResponseJSONClosure(completionHandler: completion)
       
        let uploadClosure = SnapchatAPI.prepareUploadClosure(completionHandler: completion, responseJSONClosure: responseJSONClosure)
        
        // Using Alamofire we will upload the data on a server and return
        // response with completion block
        Alamofire.upload(multipartFormData: multipartDataClosure, to: SnapchatAPIConstants.URL.uploadImage, encodingCompletion: uploadClosure)
    }
    
    static func prepareMultiPartDataClosure(image: Data) -> (MultipartFormData) -> () {
        let multipartDataClosure = { (multipartData: MultipartFormData) in
            multipartData.append(image, withName: SnapchatAPIConstants.Parameters.imageFile, fileName:  "file.jpg", mimeType: "image/jpeg")
            multipartData.append("\(SnapchatAPIConstants.userId)".data(using: .utf8)!, withName: SnapchatAPIConstants.Parameters.fromUserID)
        }
        return multipartDataClosure
    }
    
    static func preapreResponseJSONClosure(completionHandler: @escaping APICompletionHandler) -> (DataResponse<Any>) -> () {
        let responseJSONClosure = { (response: DataResponse<Any>) in
            if let statusCode = response.response?.statusCode , 400...510 ~= statusCode {
                if let response = response.result.value as? [String: AnyObject] {
                    if let message = response["error"] as? String {
                        completionHandler(SnapchatAPIConstants.Error.alamofireResultError(withMessage: message))
                    } else {
                        completionHandler(SnapchatAPIConstants.Error.alamofireUnknownError)
                    }
                }
            }
            completionHandler(response.result)
        }
        
        return responseJSONClosure
    }
    
    static func prepareUploadClosure(completionHandler: @escaping APICompletionHandler , responseJSONClosure: @escaping(DataResponse<Any>) -> () ) -> (SessionManager.MultipartFormDataEncodingResult) -> () {
        let uploadClosure = { (result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .success(let upload, _, _):
                upload.responseData { response in
                    switch response.result {
                    case .success(let data):
                        print("Success: \(String(data: data, encoding: .utf8))")
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                upload.responseJSON(completionHandler: responseJSONClosure)
            case .failure:
                completionHandler(SnapchatAPIConstants.Error.alamofireEncodingError)
            }
        }
        
        return uploadClosure

    }
    
    /// Uploads image, but only to specific user
    static func upload(image: UIImage, toUser userId: Int, completion: @escaping APICompletionHandler) {
        let multipartFormData: APIMultipartFormData = { multipartData in
            multipartData.append("\(userId)".data(using: .utf8)!, withName: SnapchatAPIConstants.Parameters.toUserID)
        }
        upload(image: image, multipartFormData: multipartFormData, completion: completion)
    }
    
    /// Fetch images that were sent to everyone
    static func getImages(parameters: [String: AnyObject]? = nil, completion: @escaping APICompletionHandler) {
        Alamofire.request(SnapchatAPIConstants.URL.getImages).responseJSON { response in
            completion(response.result)
        }
    }
    
    /// Fetch images that were sent to you OR to everyone
    static func getImages(forUser userId: Int, completion: @escaping APICompletionHandler) {
        getImages(parameters: [SnapchatAPIConstants.Parameters.toUserID: userId as AnyObject], completion: completion)
    }
    
    /// Download image with url
    static func downloadImage(_ url: String, completionHandler: @escaping APIImageCompletionHandler) {
        Alamofire
            .request(url, method: SnapchatAPIConstants.Method.downloadImage).responseImage{ (response) in
                completionHandler(response.result)
        }
    }
    
    static func removeImage(forUser userId: Int?, fileName: String, completionHandler: @escaping APICompletionHandler) {
        var parameters = ["file_name": fileName]
        
        if let userId = userId {
            parameters["to_userId"] = "\(userId)"
        }
        
        Alamofire.request(SnapchatAPIConstants.URL.removeImage, method: SnapchatAPIConstants.Method.removeImage, parameters:parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON { response in
                completionHandler(response.result)
        }
    }
}

extension UIImage {
    func toData(withCompressQuality compressQuality: CGFloat = 0.8) -> Data? {
        return UIImageJPEGRepresentation(self, compressQuality) as Data?
    }
}
