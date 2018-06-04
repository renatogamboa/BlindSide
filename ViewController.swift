//
//  ViewController.swift
//  BlindSide
//
//  Created by Martin Gamboa on 6/3/18.
//  Copyright © 2018 RenatoGamboa. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var current: String?
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Assign AVCaptureSession
        let captureSession = AVCaptureSession()
        
        // Set default camera session to cropped photo style
        captureSession.sessionPreset = .photo
        
        // Initiate Capture device to default or rear camera
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // try to use rear camera as the input capture device
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        // Use the rear camera for the capture session
        captureSession.addInput(input)
        
        // Start Running AVCaptureSession
        captureSession.startRunning()
        
        // Initiate preview layer as camera capture session
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // Add sublayer previewLater to view
        view.layer.addSublayer(previewLayer)
        
        // Set frame of the preview later to the same the the view
        previewLayer.frame = view.frame
        
        // Define Data Output
        let dataOutput = AVCaptureVideoDataOutput()
        
        // Connect to Output Delegate
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        // Add output to captureSession
        captureSession.addOutput(dataOutput)
        
        
        //VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform()
        
        // Code for label

        label?.sizeToFit()
        label?.adjustsFontSizeToFitWidth = true
        label?.numberOfLines = 2
        label?.textAlignment = .center
        label?.text = current
        label?.textColor = UIColor.red
        self.view.addSubview(label!)
        
    }
    
    // This function gives us access to what the camera is seeing
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Test Print
        //print("Camera was able to capture a frame:", Date())
        
        //Declare pixel buffer
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Declare ml Model
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        // Declare request with model
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            // check for err if occured
            //print(finishedReq.results)
            
            // Declare results from capture session
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            // assign the first result from the results array
            guard let firstObservation = results.first else { return }
            
            // Test print for first observation with percentage confidence level
            print(firstObservation.identifier, firstObservation.confidence)
            
            var percent = round(firstObservation.confidence * 10000)/100
            
            // Change UILabel text
            DispatchQueue.main.async {
                self.label?.text = "\(firstObservation.identifier) \n %\(percent)"
            }
            
        }
        
        // Try VNImageRequest
       try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

