//
//  HomeViewController.swift
//  Ascent
//
//  Created by Vevek Selvam on 7/7/16.
//  Copyright © 2016 Vevek Selvam. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import CoreLocation
import CoreBluetooth
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import FirebaseAnalytics

class HomeViewController: UIViewController, CLLocationManagerDelegate{
    
    // Buttons
    @IBOutlet weak var needHelpButton: UIButton!
    @IBOutlet weak var imOkayButton: UIButton!
    @IBOutlet weak var enableButton: UIButton!
    
    // Variables for Accelerometer
    var accelx: Double = 0
    var accely: Double = 0
    var accelz: Double = 0
    var x = "Hello"
    var y = "Hello"
    var z = "Hello"
    var total: Double = 0.0;
    var min = false;
    var max = false;
    var i: Double = 0;
    
    
    // Labels
    @IBOutlet weak var AccelerometerXLabel: UILabel!
    @IBOutlet weak var AccelerometerYLabel: UILabel!
    @IBOutlet weak var AccelerometerZLabel: UILabel!
    @IBOutlet weak var AccelerometerTLabel: UILabel!
    @IBOutlet weak var FallDetectedLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    
    // Audio
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    // Accelerometer
    let manager = CMMotionManager()
    
    // Location
    var currentLocationLatitude: Double = 0.0
    var currentLocationLongitude: Double = 0.0
    var locationManager: CLLocationManager!
    
    
    
    @IBAction func imOkayButtonPress(sender: AnyObject) {
        
        let imOkayAlertView = UIAlertController(title: "Great to hear!", message: "Please take care.", preferredStyle: .Alert)
        
        imOkayAlertView.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        
        presentViewController(imOkayAlertView, animated: true, completion: {(imOkayAlertAction) -> Void in
            self.imOkayNoEmergency()})
    }
    
    @IBAction func needHelpButtonPress(sender: AnyObject) {
        
        let needHelpAlertView = UIAlertController(title: "Request for help sent!", message: "Your emergency contacts have been alerted.", preferredStyle: .Alert)
        
        needHelpAlertView.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: {(needHelpAlertAction) -> Void in
            self.needHelpEmergency()}))
        
        presentViewController(needHelpAlertView, animated: true, completion: {(needHelpAlertAction) -> Void in
            self.needHelpEmergency()})
    }
    
    func imOkayNoEmergency(){
        viewDidLoad()
        viewWillAppear(true)
        audioPlayer.stop()
    }
    
    
    func needHelpEmergency(){
        audioPlayer.stop()
        
        // MARK: Location Manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        

        
    }


    
    @IBAction func EnableButton(sender: AnyObject) {
        
        
        enableButton.hidden = true
        FallDetectedLabel.hidden = false;
        
        if manager.accelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.01
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMAccelerometerData?, error: NSError?) in
                if let acceleration = data?.acceleration {
                    
                    self!.accelx = acceleration.x
                    self!.accely = acceleration.y
                    self!.accelz = acceleration.z
                    
                    self!.accelx = self!.accelx *  9.81
                    self!.x = String(self!.accelx)
                    self!.AccelerometerXLabel.text = self!.x
                    
                    self!.accely = self!.accely *  9.81
                    self!.y = String(self!.accely)
                    self!.AccelerometerYLabel.text = self!.y
                    
                    self!.accelz = self!.accelz *  9.81
                    self!.z = String(self!.accelz)
                    self!.AccelerometerZLabel.text = self!.z
                    
                    self!.total = sqrt(pow(self!.accelx, 2) + pow(self!.accely, 2) + pow(self!.accelz, 2))
                    self!.AccelerometerTLabel.text = String(self!.total)
                    
                    
                    if(self!.total <= 5){
                        self!.min = true;
                    }
                    
                    if(self!.min == true){
                        self!.i = self!.i + 1;
                        
                        //MEANT TO BE 20
                        if(self!.total>=17){
                            self!.max = true;
                        }
                    }
                    
                    if(self!.min == true && self!.max == true){
                        self!.FallDetectedLabel.text = "Fall Detected!"
                        self!.FallDetectedLabel.textColor = UIColor.cyanColor()
                        self!.i = 0;
                        self!.min = false;
                        self!.max = false;
                        self!.imOkayButton.hidden = false
                        self!.needHelpButton.hidden = false
                        self!.audioPlayer.play()
                    }
                    
                    if(self!.i>4){
                        self!.i = 0;
                        self!.min = false;
                        self!.max = false;
                    }
                    
                }
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FallDetectedLabel.hidden = true
        imOkayButton.hidden = true
        needHelpButton.hidden = true
        enableButton.hidden = false
        
        
        let audioPath = NSBundle.mainBundle().pathForResource("Alarm", ofType: "mp3")!
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
        } catch {
            // Process error here
        }
        

        
    }

    //MARK: Location Manager Funtion
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var userLocation:CLLocation = locations[0] as! CLLocation
        let currentLocationLongitude = userLocation.coordinate.longitude;
        let currentLocationLatitude = userLocation.coordinate.latitude;
        
        //Do What ever you want with it
        self.latLabel.text = String(currentLocationLatitude)
        self.longLabel.text = String(currentLocationLongitude)
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
