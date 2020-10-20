//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Abhirajsinh Thakore on 20/10/20.
//  Copyright © 2020 Brian Gomes. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreData
import SwiftyJSON
import Alamofire

class ScanVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imgScanner: UIImageView!
    
    var session = AVCaptureSession()
    var requests = [VNRequest]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSegue(withIdentifier: "cartSegue", sender: nil)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        startLiveVideo()
        startBarcodeDetection()
    }
    
    override func viewDidLayoutSubviews() {
        self.imgScanner.layer.sublayers?[0].frame = imgScanner.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session.stopRunning()
    }
    
    //MARK:- Start Camera and Delegate
    
    func startLiveVideo() {
        // Enable live stream video
        //get instance of phone camera
        
        //try to enable auto focus
        
        self.session.sessionPreset = AVCaptureSession.Preset.photo
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        if(captureDevice.isFocusModeSupported(.continuousAutoFocus)) {
            try! captureDevice.lockForConfiguration()
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.unlockForConfiguration()
        }
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        // Set the quality of the video
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        // What the camera is seeing
        if session.inputs.isEmpty {
            self.session.addInput(deviceInput)
        }
        
        // What we will display on the screen
        if session.outputs.isEmpty{
        self.session.addOutput(deviceOutput)
        }
        // Show the video as it's being captured
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.imgScanner.bounds
        self.imgScanner.layer.addSublayer(previewLayer)
        
        self.session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions: [VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics : camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    //MARK:- Barcode Detection
    
    
    func startBarcodeDetection() {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: self.detectBarcodeHandler)
        self.requests = [barcodeRequest]
    }
    
    // Handle barcode detection requests
    func detectBarcodeHandler(request: VNRequest, error: Error?) {
        if error != nil {
            print(error!)
        }
        guard let barcodes = request.results else {
            return
        }

        // Perform UI updates on the main thread
        DispatchQueue.main.async {
            if self.session.isRunning {
                
                // This will be used to eliminate duplicate findings
                var barcodeObservations: [String : VNBarcodeObservation] = [:]
                for barcode in barcodes {
                    if let potentialQRCode = barcode as? VNBarcodeObservation {
                        if potentialQRCode.symbology == .EAN13 || potentialQRCode.symbology == .UPCE{
                            barcodeObservations[potentialQRCode.payloadStringValue ?? ""] = potentialQRCode
                        }
                    }
                }
                
                for (barcodeContent, _) in barcodeObservations {
                    self.session.stopRunning()
                    if let arrProducts = self.getBarcodeData(barcodeContent){
                        for data in arrProducts{
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.arrProductData.append(data)
                        }
                        //Set the navigation to next screen here.
                    }else{
                        
                        let alert = UIAlertController(title: "Alert", message: "Item Not Found Please try another item.", preferredStyle: .alert)
                      
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            print("Start Scanning Again")
                            self.startLiveVideo()
                            self.startBarcodeDetection()
                        }))
                        

                        self.present(alert, animated: true)
                        
                        print("No Data Found")
                    }
                }
            }
        }
    }
    
    func getBarcodeData(_ strCode:String) -> [[String:Any]]?{
        var data:Data!
        do {
          
            
            if let url = URL(string: "https://api.barcodelookup.com/v2/products?barcode=\(strCode)&formatted=y&key=kx1zbmiwt2cms3ev85x53ysokb6yh6"){
                try data = Data(contentsOf: url)
                if let arrData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                    if let arrProducts = arrData["products"] as? [[String:Any]], arrProducts.count > 0{
                        return arrProducts
                    }
                }
            }
        }
        catch {
            print("Error: \(error)")
        }
        return nil
    }
}
