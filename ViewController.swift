//
//  ViewController.swift
//  ml_object_detection
//
//  Created by zheng wu on 1/23/18.
//  Copyright © 2018 zhengwu. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet var name_label: UILabel!
    
    @IBOutlet var accuracy_label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        name_label.layer.zPosition = 1
        accuracy_label.layer.zPosition = 1
        
        
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
        print("Can I reach here?")
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label:"videoQueue"))
        captureSession.addOutput(dataOutput)
        //VNImageRequestHandler(CGImage: CGImage, options:[:].perform(request:[VNRequest]))
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       // print("Camera was able to capture a frame!")
        guard let pixelButffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: VGG16().model) else { return }
        let request = VNCoreMLRequest(model:model){(finishedReq,err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            DispatchQueue.main.async {
                self.name_label.text = firstObservation.identifier
                self.accuracy_label.text = String(firstObservation.confidence)
            }
           // self.name_label.text = firstObservation.identifier
            
           // print(firstObservation.identifier,firstObservation.confidence)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelButffer, options: [:]).perform([request])
    }


}

