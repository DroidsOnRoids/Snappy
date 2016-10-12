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
    
    static fileprivate let defaultQueryImagePixelsWidth = 1080.0
    static fileprivate let defaultQeryImagePixelsHeight = 1080.0
    
    // MARK: Private methods
    
    fileprivate static func addOutput() {
        guard let session = self.session else { return }
        session.beginConfiguration()
        if let output = imageOutput {
            session.removeOutput(output)
        }
        
        imageOutput = AVCaptureStillImageOutput()
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        guard let output = imageOutput else { return }
        DispatchQueue.main.async {
            let outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            output.outputSettings = outputSettings
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
        }
    }
    
    fileprivate static func setCamera(_ device: AVCaptureDevice, completion: @escaping (_ sessionPreviewView: UIView?) -> ()) {
        var input: AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: device)
            session?.addInput(input)
            
            DispatchQueue.main.async {
                // Create layer to show preview - set aspect fill mode
                captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                if let captureLayer = captureVideoPreviewLayer, let previewView = previewView {
                    captureLayer.frame = previewView.frame
                    previewView.layer.addSublayer(captureLayer)
                }
                
                session?.commitConfiguration()
                session?.startRunning()
                
                completion(previewView ?? nil)
            }
            
        } catch(let error) {
            print(error)
        }
    }
    
    fileprivate static func backCamera() -> AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) ?? nil
    }
    
    fileprivate static func frontCamera() -> AVCaptureDevice? {
        for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
            if let captureDevice = device as? AVCaptureDevice , (device as AnyObject).position == .front {
                return captureDevice
            }
        }
        
        return nil
    }
    
    fileprivate static func cropImage(_ image: UIImage?) -> UIImage? {
        if let image = image {
            let orginalOrientation = image.imageOrientation
            let cropRect = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.width)
            let imageRef = image.cgImage?.cropping(to: cropRect)
            var croppedImage: UIImage?
            if let imageRef = imageRef {
                croppedImage = UIImage(cgImage: imageRef)
                if (croppedImage?.size.width)! > CGFloat(defaultQueryImagePixelsWidth) {
                    croppedImage = croppedImage?.scaledToSize(CGSize(width: defaultQueryImagePixelsWidth,
                        height: defaultQeryImagePixelsHeight))
                }
                
                if let croppedImageRef = croppedImage?.cgImage {
                    croppedImage = UIImage(cgImage: croppedImageRef, scale: croppedImage?.scale ?? 1.0, orientation: orginalOrientation)
                }
            }
            return croppedImage
        }
        
        return nil
    }
}

// MARK: EXTENSIONS

extension CameraManager: CameraManagerProtocol {
    
    static func generateCameraPreview(previewSize size: CGSize, completion: @escaping (_ sessionPreviewView: UIView?) -> ()) {
        frontCameraOn = false
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSessionPresetPhoto
        
        previewView = UIView(frame: CGRect(x: 0.0,
            y: 0.0,
            width: size.width,
            height: size.height))
        addOutput()
        
        guard let backCamera = backCamera() else {
            completion(nil)
            
            return
        }
        
        setCamera(backCamera, completion: { sessionPreviewView in
            completion(sessionPreviewView)
        })
    }
    
    static func switchCamera(_ completion: @escaping (_ sessionPreviewView: UIView?) -> ()) {
        guard let session = self.session, let currentCameraInput = session.inputs.first as? AVCaptureInput else { return }
        
        frontCameraOn = !frontCameraOn
        session.beginConfiguration()
        session.removeInput(currentCameraInput)
        session.sessionPreset = AVCaptureSessionPresetPhoto
        var newCameraDevice: AVCaptureDevice?
        if (currentCameraInput as? AVCaptureDeviceInput)?.device.position == .back {
            newCameraDevice = frontCamera()
        } else {
            newCameraDevice = backCamera()
        }
        
        if let newCamera = newCameraDevice {
            setCamera(newCamera, completion: { sessionPreviewView in
                completion(sessionPreviewView)
            })
        } else {
            completion(nil)
        }
    }
    
    static func toggleFlashMode(_ bool: Bool) {
        guard let session = session,
              let currentCameraInput = session.inputs.first as? AVCaptureDeviceInput,
              let device = backCamera()
              , currentCameraInput.device.position == .back else { return }
        
        if device.hasFlash && device.hasTorch {
            do {
                try device.lockForConfiguration()
            } catch (let error) {
                print(error)
            }
            
            device.torchMode = bool ? .on : .off
            device.flashMode = bool ? .on : .off
            device.unlockForConfiguration()
        }
    }
    
    static func takePhoto(_ completion: @escaping (UIImage?) -> ()) {
        var image: UIImage?
        guard let videoConnection =  imageOutput?.connection(withMediaType: AVMediaTypeVideo) else {
            completion(image)
            return
        }
        
        videoConnection.videoOrientation = .portrait
        imageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { dataBuffer, error in
            guard let buffer = dataBuffer else {return }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            let dataProvider = CGDataProvider(data: imageData as! CFData)
            
            if let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: frontCameraOn ? .leftMirrored : .right)
            }
            
            completion(image)
        })
    }
}

extension UIImage {
    
    func scaledToSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
