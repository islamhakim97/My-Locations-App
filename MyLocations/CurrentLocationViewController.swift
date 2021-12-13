//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by Islam Abd El Hakim on 26/11/2021.
//

import UIKit
import CoreLocation // add Core Location Frame Work to ur project
import CoreData
import AudioToolbox//You’re going to add a sound effect to the app too, which is to be played when the firstReverse geocoding successfully completes
class CurrentLocationViewController: UIViewController , CLLocationManagerDelegate,CAAnimationDelegate{
    var soundID:SystemSoundID = 0 //0 means no sound has been loaded yet.
    let LocationManager =  CLLocationManager()// to get GPS coordinates , but it doesnt give u gps coordinates right away so you wiil invoke its startUpdatingLocation() method
    @IBOutlet weak var messagelabel: UILabel!
    @IBOutlet weak var latitudelabel: UILabel!
   
    @IBOutlet weak var longitudelabel: UILabel!
    @IBOutlet weak var tagbutton: UIButton!
    @IBOutlet weak var addresslabel: UILabel!
    @IBOutlet weak var latlabel: UILabel!
    @IBOutlet weak var longlabel: UILabel!
    @IBOutlet weak var getmylocationbutton: UIButton!
    @IBOutlet weak var containerView: UIView!
    var location:CLLocation?
    var updatingLocation = false // for handling gps error
    /* If it is false, then the location manager isn’t
    currently active and there’s no need to stop it*/
    var lastLocationErorr:Error?
    let geocoder = CLGeocoder()
    var performingReverseGeocoding = false
    var lastGeocodingError:Error?
    var placeMark:CLPlacemark? /* CLPlacemark is the object that contains the address
    results.*/
    var timer:Timer?
    var managedObjectContext:NSManagedObjectContext!
    var logoVisible = false
    // FOR logo screen
    lazy var logoButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setBackgroundImage(UIImage(named: "Logo"),
    for: .normal)
    button.sizeToFit()
    button.addTarget(self, action: #selector(getLocation),
    for: .touchUpInside)
    button.center.x = self.view.bounds.midX
    button.center.y = 220
    return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetbutton()
        navigationController?.isNavigationBarHidden=true
        loadSoundEffect("Sound.caf")
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden=false
    }
    // MARK:- Sound effects
    func loadSoundEffect(_ name: String) {
          if let path = Bundle.main.path(forResource: name,ofType: nil) {
          let fileURL = URL(fileURLWithPath: path, isDirectory: false)
          let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
          if error != kAudioServicesNoError {
                print("Error code \(error) loading sound: \(path)")
          }
          }
    }
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    func playSoundEffect() {
         AudioServicesPlaySystemSound(soundID)
    }
    // MARK:- Get Location
    @IBAction func getMyLocationbtn(_ sender: Any) {
        getLocation()
        updateLabels()
        configureGetbutton()
    }
    func showLogoView()
    {
          if !logoVisible {
                 logoVisible = true
                 containerView.isHidden = true
                 view.addSubview(logoButton)
          }
    }
    func hideLogoView() {
        if !logoVisible { return }
        logoVisible = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 +
        containerView.bounds.size.height / 2
        let centerX = view.bounds.midX
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = CAMediaTimingFillMode.forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint:
        CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(
        name: CAMediaTimingFunctionName.easeOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = CAMediaTimingFillMode.forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint:
        CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(
        name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        let logoRotator = CABasicAnimation(keyPath:
        "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = CAMediaTimingFillMode.forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(
        name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
        
    }
    // MARK:- Animation Delegate Methods
    func animationDidStop(_ anim: CAAnimation,finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 +
        containerView.bounds.size.height / 2
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    @objc func getLocation()
    {
        // Get Permission for use Device location
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .denied||authStatus == .restricted
        {
            showLocationServicesDeniedError()
            return
        }
        if authStatus == .notDetermined
        {
            LocationManager.requestWhenInUseAuthorization()// request premission for use location
            return
        }
        if logoVisible{hideLogoView()}
        // you’re using the updatingLocation flag to determine what state the app is
        if updatingLocation
        {
            stopLocationManager()
        }else
        {
            location=nil
            lastLocationErorr=nil
            placeMark=nil //clear placemark
            lastGeocodingError=nil // clear gecofing errors to start in aclear state
            startLocationManager()
        }
        
    }
    // speaking with location manager delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      //  print("didFailWithError\(error.localizedDescription)")
        if (error as NSError).code == CLError.locationUnknown.rawValue
        {
            return
        }
        lastLocationErorr=error
        stopLocationManager()
        updateLabels()
        configureGetbutton()
        
       
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
        let newlocation = locations.last!
       // print("didUpdateLocations : \(newlocation)")
        //improving gps results
        if newlocation.timestamp.timeIntervalSinceNow < -5 {
        return
        }
        // 2
        if newlocation.horizontalAccuracy < 0 {
        return
        }
        /********************************
         The problem with the iPod touch is that it doesn’t have GPS, so it relies only on WiFi to determine the location
         But Wi-Fi might not be able to give you accuracy up to
         ten meters; I got +/- 100 meters at best SO: FirstFix...
         **************************************************/
        // New section #1
        var distance = CLLocationDistance(
        Double.greatestFiniteMagnitude)
        if let location = location {
        distance = newlocation.distance(from: location)
        }
        // End of new section #1
        if location == nil || location!.horizontalAccuracy >
        newlocation.horizontalAccuracy {
        if newlocation.horizontalAccuracy <=
            LocationManager.desiredAccuracy {
        // New section #2
        if distance > 0 {
        performingReverseGeocoding = false
        }
        // End of new section #2
        }
        updateLabels()
        if !performingReverseGeocoding {
        }
        // New section #3
        } else if distance < 1 {
        let timeInterval = newlocation.timestamp.timeIntervalSince(
        location!.timestamp)
        if timeInterval > 10 {
        //print("*** Force done!")
        stopLocationManager()
        updateLabels()
        }
        // End of new sectiton #3
        }
        
            
        //********************************************** 3
//if this is the very first location reading (location is nil)
        if location == nil || location!.horizontalAccuracy >
        newlocation.horizontalAccuracy {
/* 4 It clears out any previous error and stores the new
            CLLocation object into the location variable.*/
             lastLocationErorr=nil
             location = newlocation
        // 5
        if newlocation.horizontalAccuracy <=
        LocationManager.desiredAccuracy{
// print("*** We’re done!")
        stopLocationManager()
        }
        updateLabels()
//The app should only perform a single reverse geocoding request at a time.
            if !performingReverseGeocoding
            {
               // print("*** Going to geocode")
                performingReverseGeocoding=true
                geocoder.reverseGeocodeLocation(newlocation,
                                                completionHandler:
                                                    {
                    placemarks,error in
                    self.lastGeocodingError = error // put error in avariable so u cane refrence to it later
                    if error == nil, let p = placemarks, !p.isEmpty {
// New code block For Founding adrress For the First Time play this sound affect
                        if self.placeMark == nil {
                       // print("FIRST TIME!")
                        self.playSoundEffect()
                        }
                        // End new code
                    self.placeMark = p.last!
                    } else {
                    self.placeMark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                    
                }
                )
            }
        configureGetbutton()
        }
    }
   func showLocationServicesDeniedError()
    {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please Enable Location Service For This App in Settings", preferredStyle:.alert)
        let OkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(OkAction)
        present(alert, animated: true, completion: nil)
        
    }
    func updateLabels()
    {
        
        if let location = location {
            messagelabel.text=""
            latitudelabel.text=String(format:"%.8f",location.coordinate.latitude) // string Format To Control decimal flow numbers in latitude after point 8 didgits only
            longitudelabel.text=String(format:"%.8f",location.coordinate.longitude)
            addresslabel.text=""
            tagbutton.isHidden=false
            longlabel.isHidden = false
            latlabel.isHidden = false
            addresslabel.isHidden = false
        }
        else
        {
            let statusMessage:String
           
             if let error = lastLocationErorr as NSError?
            {
                 if error.domain == kCLErrorDomain &&
                        error.code == CLError.denied.rawValue
                 {
                     statusMessage="Location Service Disabled"
                 }
                 else
                 {
                     statusMessage="Error Getting Location"
                 }
            }else if  !CLLocationManager.locationServicesEnabled()
            {
               statusMessage="Location Service Disabled"
            }else if updatingLocation
            {
                statusMessage="Searching....."
            }
            else
            {
                //startUp Time
                statusMessage=""
                showLogoView()
            }
            messagelabel.text = statusMessage
            tagbutton.isHidden=true
            latitudelabel.text = ""
            longitudelabel.text = ""
            addresslabel.text=""
            longlabel.isHidden = true
            latlabel.isHidden = true
            addresslabel.isHidden = true
            
        }
        // handling error for Reverse Geocoding
      if let placemark=placeMark
        {
          addresslabel.text = string(from : placemark)
        }
        else if performingReverseGeocoding
        {
            addresslabel.text="searching For Address..."
        }
        else if (lastGeocodingError != nil)
        {
            addresslabel.text = "Error Finding Adress..."
        }
        else
        {
            addresslabel.text="No Address Found"
        }
            
        
    }
    func stopLocationManager()
    {
        /* If it is false, then the location manager isn’t
        currently active and there’s no need to stop it*/
        if updatingLocation{
            LocationManager.stopUpdatingLocation()
            LocationManager.delegate=nil
            updatingLocation=false
        }
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    func startLocationManager()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            LocationManager.delegate = self // viewcontroller is its delegate
            LocationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters// k for konstant
            LocationManager.startUpdatingLocation()//start LOCATION MANAGER , getting GPS Coordinates
            updatingLocation=true
            /*You can tell iOS to perform a
             method one minute from now. If by that time the app hasn’t found a location yet,
             you stop the location manager and show an error message  */
           timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector:#selector (didTimeOut), userInfo: nil, repeats: false)
        }
    }
    // updating the UI Get Location Buttom
    func configureGetbutton()
    {
        let spinnerTag = 1000
        if updatingLocation {
            getmylocationbutton.setTitle("Stop", for: .normal)
            if view.viewWithTag(spinnerTag) == nil {
            let spinner = UIActivityIndicatorView(style: .white)
            spinner.center = messagelabel.center
            spinner.center.y += spinner.bounds.size.height/2 + 25
            spinner.startAnimating()
            spinner.tag = spinnerTag
            containerView.addSubview(spinner)}
            } else {
            getmylocationbutton.setTitle("Get My Location", for: .normal)
            if let spinner = view.viewWithTag(spinnerTag) {
            spinner.removeFromSuperview()}
            }
        /*
        if updatingLocation
        {
            getmylocationbutton.setTitle("Stop", for: .normal)
        }
        else
        {
            getmylocationbutton.setTitle("Get My Location", for: .normal)
        }*/
    }
    //The address will be two lines of text
    func string(from  placemark :CLPlacemark ) -> String
    {
        var line1 = ""
        // 2 subthroughfare = housenumber
        if let s = placemark.subThoroughfare {
        line1 += s + " "
        }
        // 3 thoroughfare= street number
        if let s = placemark.thoroughfare {
        line1 += s
        }
        // 4
        var line2 = ""
        // locality = city
        if let s = placemark.locality {
        line2 += s + " "
        }
        // administrativeArea= state or province
        if let s = placemark.administrativeArea {
        line2 += s + " "
        }
        //ZipCode
        if let s = placemark.postalCode {
        line2 += s
        }
        // 5
        return line1 + "\n" + line2
    }
    //stop location manager , present error if found
    @objc func didTimeOut()
    {
       // print("*** Time Out")
        if location == nil
        {
            stopLocationManager()
            lastLocationErorr=NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()// update the screen
        }
    }
    // pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="TagLocation"
        {
            let controller = segue.destination as! LocationDetailsViewController
            controller.placemark=placeMark
            controller.coordinates = location!.coordinate
            // passing managedObjectContext to sceneDelegate
            controller.managedObjectContext=managedObjectContext
            
        }
    }
    
    
   

}

