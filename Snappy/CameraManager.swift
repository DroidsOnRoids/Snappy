//
//  CameraManager.swift
//  Flashpick-iOS
//
//  Created by Paweł Sternik on 05.02.2016.
//  Copyright © 2016 Paweł Sternik. All rights reserved.
//

// Frameworks
import Foundation
import AVFoundation
import UIKit

class CameraManager {
    
    static var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    static var session: AVCaptureSession?
    static var previewView: UIView?
    static var imageOutput: AVCaptureStillImageOutput?
    static var frontCameraOn = false
    
    static private let defaultQueryImagePixelsWidth = 1080.0
    static private let defaultQeryImagePixelsHeight = 1080.0
    
    // MARK: Private methods
    
    private static func addOutput() {
        guard let session = self.session else { return }
        session.beginConfiguration()
        if let output = imageOutput {
            session.removeOutput(output)
        }
        
        imageOutput = AVCaptureStillImageOutput()
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        guard let output = imageOutput else { return }
        dispatch_async(dispatch_get_main_queue()) {
            let outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            output.outputSettings = outputSettings
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
        }
    }
    
    private static func setCamera(device: AVCaptureDevice, completion: (sessionPreviewView: UIView?) -> ()) {
        var input: AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: device)
            session?.addInput(input)
            
            dispatch_async(dispatch_get_main_queue()) {
                // Create layer to show preview - set aspect fill mode
                captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                if let captureLayer = captureVideoPreviewLayer, let previewView = previewView {
                    captureLayer.frame = previewView.frame
                    previewView.layer.addSublayer(captureLayer)
                }
                
                session?.commitConfiguration()
                session?.startRunning()
                
                completion(sessionPreviewView: previewView ?? nil)
            }
            
        } catch(let error) {
            print(error)
        }
    }
    
    private static func backCamera() -> AVCaptureDevice? {
        return AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) ?? nil
    }
    
    private static func frontCamera() -> AVCaptureDevice? {
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            if let captureDevice = device as? AVCaptureDevice where device.position == .Front {
                return captureDevice
            }
        }
        
        return nil
    }
    
    private static func cropImage(image: UIImage?) -> UIImage? {
        if let image = image {
            let orginalOrientation = image.imageOrientation
            let cropRect = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.width)
            let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect)
            var croppedImage: UIImage?
            if let imageRef = imageRef {
                croppedImage = UIImage(CGImage: imageRef)
                if croppedImage?.size.width > CGFloat(defaultQueryImagePixelsWidth) {
                    croppedImage = croppedImage?.scaledToSize(CGSize(width: defaultQueryImagePixelsWidth,
                        height: defaultQeryImagePixelsHeight))
                }
                
                if let croppedImageRef = croppedImage?.CGImage {
                    croppedImage = UIImage(CGImage: croppedImageRef, scale: croppedImage?.scale ?? 1.0, orientation: orginalOrientation)
                }
            }
            return croppedImage
        }
        
        return nil
    }
}

// MARK: EXTENSIONS

extension CameraManager: CameraManagerProtocol {
    
    static func generateCameraPreview(previewSize size: CGSize, completion: (sessionPreviewView: UIView?) -> ()) {
        frontCameraOn = false
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSessionPresetPhoto
        
        previewView = UIView(frame: CGRect(x: 0.0,
            y: 0.0,
            width: size.width,
            height: size.height))
        addOutput()
        
        guard let backCamera = backCamera() else {
            completion(sessionPreviewView: nil)
            
            return
        }
        
        setCamera(backCamera, completion: { sessionPreviewView in
            completion(sessionPreviewView: sessionPreviewView)
        })
    }
    
    static func switchCamera(completion: (sessionPreviewView: UIView?) -> ()) {
        guard let session = self.session, currentCameraInput = session.inputs.first as? AVCaptureInput else { return }
        
        frontCameraOn = !frontCameraOn
        session.beginConfiguration()
        session.removeInput(currentCameraInput)
        session.sessionPreset = AVCaptureSessionPresetPhoto
        var newCameraDevice: AVCaptureDevice?
        if (currentCameraInput as? AVCaptureDeviceInput)?.device.position == .Back {
            newCameraDevice = frontCamera()
        } else {
            newCameraDevice = backCamera()
        }
        
        if let newCamera = newCameraDevice {
            setCamera(newCamera, completion: { sessionPreviewView in
                completion(sessionPreviewView: sessionPreviewView)
            })
        } else {
            completion(sessionPreviewView: nil)
        }
    }
    
    static func toggleFlashMode(bool: Bool) {
        guard let session = self.session,
            currentCameraInput = session.inputs.first as? AVCaptureDeviceInput,
            device = backCamera()
            where currentCameraInput.device.position == .Back else { return }
        
        if device.hasFlash && device.hasTorch {
            do {
                try device.lockForConfiguration()
            } catch (let error) {
                print(error)
            }
            
            device.torchMode = bool ? .On : .Off
            device.flashMode = bool ? .On : .Off
            device.unlockForConfiguration()
        }
    }
    
    static func takePhoto(completion: (UIImage?) -> ()) {
        var image: UIImage?
        guard let videoConnection =  imageOutput?.connectionWithMediaType(AVMediaTypeVideo) else {
            completion(image)
            
            return
        }
        
        videoConnection.videoOrientation = .Portrait
        imageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { dataBuffer, error in
            guard let buffer = dataBuffer else {return }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            let dataProvider = CGDataProviderCreateWithCFData(imageData)
            
            if let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault) {
                image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: frontCameraOn ? .LeftMirrored : .Right)
            }
            
            completion(image)
        })
    }
    
    
}

extension UIImage {
    
    func scaledToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        self.drawInRect(CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}