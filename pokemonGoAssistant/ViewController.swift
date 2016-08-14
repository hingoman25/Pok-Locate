    //
//  ViewController.swift
//  pokemonGoAssistant
//
//  Created by Anthony Kim on 7/15/16.
//  Copyright (c) 2016 anthonykim. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON


class ViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var report: UIButton!
    
    let pop = UIView()
    let shadow = UIView()
    let pokemonImage = UIImageView()
    let time = UILabel()
    let distance = UILabel()
    let location = UILabel()
    let user = UILabel()
    let userRate = UILabel()
    let postRate = UILabel()
    let likeButton = CustomButton()
    let dislikeButton = CustomButton()
    let refresh = UIButton()
    let reportButton = UIButton()
    let trackButton = UIButton()
    var error = Error()
    
    var mapHeight:CGFloat = 0.0
    var mapWidth:CGFloat = 0.0
    
    var popUpHeight:CGFloat = 0.0
    
    var selectedPokemon:String! = "pokemon name here"
    var popOut = false
    
    var orderData = ["bulbasaur", "ivysaur", "venusaur", "charmander", "charmeleon", "charizard", "squirtle", "wartortle", "blastoise", "caterpie", "metapod", "butterfree", "weedle", "kakuna", "beedrill", "pidgey", "pidgeotto", "pidgeot", "rattata", "raticate", "spearow", "fearow", "ekans", "arbok", "pikachu", "raichu", "sandshrew", "sandslash", "nidoran-f", "nidorina", "nidoqueen", "nidoran-m", "nidorino", "nidoking", "clefairy", "clefable", "vulpix", "ninetales", "jigglypuff", "wigglytuff", "zubat", "golbat", "oddish", "gloom", "vileplume", "paras", "parasect", "venonat", "venomoth", "diglett", "dugtrio", "meowth", "persian", "psyduck", "golduck", "mankey", "primeape", "growlithe", "arcanine", "poliwag", "poliwhirl", "poliwrath", "abra", "kadabra", "alakazam", "machop", "machoke", "machamp", "bellsprout", "weepinbell", "victreebel", "tentacool", "tentacruel", "geodude", "graveler", "golem", "ponyta", "rapidash", "slowpoke", "slowbro", "magnemite", "magneton", "farfetchd", "doduo", "dodrio", "seel", "dewgong", "grimer", "muk", "shellder", "cloyster", "gastly", "haunter", "gengar", "onix", "drowzee", "hypno", "krabby", "kingler", "voltorb", "electrode", "exeggcute", "exeggutor", "cubone", "marowak", "hitmonlee", "hitmonchan", "lickitung", "koffing", "weezing", "rhyhorn", "rhydon", "chansey", "tangela", "kangaskhan", "horsea", "seadra", "goldeen", "seaking", "staryu", "starmie", "mr-mime", "scyther", "jynx", "electabuzz", "magmar", "pinsir", "tauros", "magikarp", "gyarados", "lapras", "ditto", "eevee", "vaporeon", "jolteon", "flareon", "porygon", "omanyte", "omastar", "kabuto", "kabutops", "aerodactyl", "snorlax", "articuno","zapdos", "moltres", "dratini", "dragonair", "dragonite", "mewtwo", "mew"]
    var nameData = []
    
    let locationManager = CLLocationManager()
    var userLat = 0.0
    var userLon = 0.0
    var numberUpdates = 0;
    
    var canVote = 0 //whether or not buttons are enabled
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //self.mapView.removeFromSuperview()
        //self.mapView = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        print("ViewController viewDidAppear ran.")
        super.viewDidAppear(animated)
        refreshFunction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameData = orderData.sort()
        print(nameData)
        print("Map Controller View loaded.")
        
        self.userLat = 0.0
        self.userLon = 0.0
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.distanceFilter = 10
        
        //self.locationManager.startMonitoringSignificantLocationChanges()
        if #available(iOS 9.0, *) {
            self.locationManager.allowsBackgroundLocationUpdates = true
        } else {
            
        }
        
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        self.mapView.mapType = MKMapType.Standard
        self.mapView.zoomEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("removePopUp:"))
        view.addGestureRecognizer(tap)
        mapHeight = self.view.frame.size.height
        mapWidth = self.view.frame.size.width
        popUpHeight = mapHeight * 0.3
        
        // y starts above the screen for animation
        pop.frame = CGRect(x: 0, y: 0 - popUpHeight, width: mapWidth, height: popUpHeight)
        pop.backgroundColor = UIColor().HexToColor("#545c67 ", alpha: 1.0)
        pop.layer.cornerRadius = 5.0
        pop.layer.borderColor = UIColor.grayColor().CGColor
        pop.layer.borderWidth = 0.5
        
        pop.layer.shadowColor = UIColor.blackColor().CGColor
        pop.layer.shadowOffset = CGSize(width: 0, height: 3)
        pop.layer.shadowOpacity = 0.4
        pop.layer.shadowRadius = 4
        
        shadow.frame = CGRect(x: 0, y: 0, width: mapWidth, height: mapHeight)
        shadow.backgroundColor = UIColor.blackColor()
        shadow.alpha = 0
        
        let pokeSize = CGSize(width: mapHeight / 8, height: mapHeight / 8)
        pokemonImage.frame = CGRect(x: (mapWidth / 2) - (pokeSize.width / 2), y: 0, width: pokeSize.width, height: pokeSize.height)
        
        let labelSize = CGSize(width: mapWidth * 0.75, height: mapHeight / 30)
        let labelColor = UIColor().HexToColor("#f8f3eb", alpha: 1.0)
        time.frame = CGRect(x: mapWidth / 30, y: mapHeight / 40, width: labelSize.width, height: mapHeight / 40)
        distance.frame = CGRect(x: (mapWidth / 2) - (labelSize.width / 2), y: pokemonImage.frame.maxY - (pokeSize.width / 8), width: labelSize.width, height: labelSize.height)
        location.frame = CGRect(x: (mapWidth / 2) - (labelSize.width / 2), y: distance.frame.maxY, width: labelSize.width, height: labelSize.height)
        userRate.frame = CGRect(x: mapWidth / 30, y: popUpHeight - (mapHeight / 20), width: labelSize.width, height: mapHeight / 40)
        user.frame = CGRect(x: mapWidth / 30, y: userRate.frame.minY - (mapHeight / 40), width: labelSize.width, height: mapHeight / 40)
        postRate.frame = CGRect(x: mapWidth * 0.6, y: user.frame.minY, width: labelSize.width, height: mapHeight / 40)
        
        distance.textAlignment = NSTextAlignment.Center
        location.textAlignment = NSTextAlignment.Center
        
        time.font = UIFont(name: "Aleo-Regular", size: mapHeight / 52)
        distance.font = UIFont(name: "Aleo-Regular", size: mapHeight / 30)
        location.font = UIFont(name: "Aleo-Regular", size: mapHeight / 45)
        user.font = UIFont(name: "Aleo-Regular", size: mapHeight / 52)
        userRate.font = UIFont(name: "Aleo-Regular", size: mapHeight / 52)
        postRate.font = UIFont(name: "Aleo-Regular", size: mapHeight / 52)
        
        time.textColor = labelColor
        distance.textColor = labelColor
        location.textColor = labelColor
        user.textColor = labelColor
        userRate.textColor = labelColor
        postRate.textColor = labelColor
    
        time.text = "6 hours ago"
        distance.text = "0.5 miles away"
        location.text = "at Brower Court, San Ramon"
        user.text = "Submitted by AntMan623"
        userRate.text = "User's Current Rating: +0 -0"
        postRate.text = "Current Rating: 80%"
        
        let buttonSize = CGSize(width: mapWidth / 7, height: mapWidth / 7)
        likeButton.setImage(UIImage(named: "Thumbs Up"), forState: UIControlState.Normal)
        dislikeButton.setImage(UIImage(named: "Thumbs Down"), forState: UIControlState.Normal)
 
        likeButton.frame = CGRect(x: mapWidth * 0.65 + (buttonSize.width / 2), y: popUpHeight, width: 0, height: 0)
        dislikeButton.frame = CGRect(x: likeButton.frame.maxX + (buttonSize.width / 2), y: popUpHeight, width: 0, height: 0)
        
        likeButton.addTarget(self, action: Selector("likeAction:"),forControlEvents: .TouchUpInside)
        dislikeButton.addTarget(self, action: Selector("likeAction:"), forControlEvents: .TouchUpInside)
        
        let reportSize = CGSize(width: mapWidth * 0.75, height: mapHeight / 10)
        reportButton.setImage(UIImage(named: "Updated report button"), forState: UIControlState.Normal)
        reportButton.frame = CGRect(x: (mapWidth / 2) - (reportSize.width / 2), y: mapHeight * 0.825, width: reportSize.width, height: reportSize.height)
        reportButton.addTarget(self, action: Selector("reportAction:"), forControlEvents: .TouchUpInside)
        
        let refreshSize = CGSize(width: mapWidth * 0.1, height: mapWidth * 0.1)
        refresh.setImage(UIImage(named: "Refresh Button"), forState: UIControlState.Normal)
        refresh.frame = CGRect(x: mapWidth / 10, y: 30, width: refreshSize.width + 5, height: refreshSize.height)
        refresh.addTarget(self, action: Selector("refreshAction:"), forControlEvents: .TouchUpInside)
        
        trackButton.setImage(UIImage(named: "Center Button"), forState: UIControlState.Normal)
        trackButton.frame = CGRect(x: (mapWidth * 9 / 10) - refreshSize.width, y: 30, width: refreshSize.width, height: refreshSize.height)
        trackButton.addTarget(self, action: Selector("trackAction:"), forControlEvents: .TouchUpInside)
        
        /*logoutButton.setImage(UIImage(named: "Log Out Button Rounded"), forState: UIControlState.Normal)
        logoutButton.frame = CGRect(x: (refresh.frame.minX / 2) - (refreshSize.width / 2), y: refresh.frame.minY, width: refreshSize.width, height: refreshSize.height)*/
        
        //ERROR SUBVIEW
        let errorRect = CGRect(x: 0, y: -1 * mapHeight / 10, width: mapWidth, height: mapHeight / 10)
        self.error = Error(frame: errorRect)
        self.error.hidden = true
        pop.addSubview(pokemonImage)
        pop.addSubview(time)
        pop.addSubview(distance)
        pop.addSubview(location)
        pop.addSubview(user)
        pop.addSubview(userRate)
        pop.addSubview(postRate)
        self.view.addSubview(pop)
        self.view.addSubview(shadow)
        self.view.addSubview(likeButton)
        self.view.addSubview(dislikeButton)
        self.view.addSubview(reportButton)
        self.view.addSubview(refresh)
        self.view.addSubview(trackButton)
        self.view.bringSubviewToFront(shadow)
        self.view.bringSubviewToFront(pop)
        self.view.bringSubviewToFront(likeButton)
        self.view.bringSubviewToFront(dislikeButton)
        self.view.addSubview(self.error)
        //self.error.bringSubviewToFront(self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        if numberUpdates == 0 {
            let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
            self.mapView.setRegion(region, animated: true)
        } else {
            
        }
        numberUpdates = numberUpdates + 1
        userLat = locValue.latitude
        userLon = locValue.longitude
        if manager.location != nil {
            sendLocationToServer(manager.location!)
        }
        UIView.animateWithDuration(0.28, animations: {
            self.error.frame = CGRectMake(0, -1 * self.mapView.frame.height / 10, self.error.frame.width, self.error.frame.height)
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Error: " + error.localizedDescription)
        UIView.animateWithDuration(0.28, animations: {
            self.error.frame = CGRectMake(0, 0, self.error.frame.width, self.error.frame.height)
            self.error.label.text = "GPS Location Not Found"
        })
    }
    
//    @IBAction func tracked(sender: AnyObject) {
//        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("VCTracking")
//        self.showViewController(vc as! UIViewController, sender: vc)
//    }
    
    func trackAction(sender: UIButton!) {
        centerMap()
        /*let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("VCTracking")
        self.showViewController(vc as! UIViewController, sender: vc)*/
    }
    
//    @IBAction func reported(sender: AnyObject) {
//        let vc = storyboard!.instantiateViewControllerWithIdentifier("Report") as! Report
//        vc.latitude = userLat
//        vc.longitude = userLon
//        self.showViewController(vc, sender: vc)
//    }
    
    func reportAction(sender: UIButton!) {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("Report") as! Report
        vc.latitude = (locationManager.location?.coordinate.latitude)!
        print("View Controller Latitude set to: " + vc.latitude.description)
        vc.longitude = (locationManager.location?.coordinate.longitude)!
        print("View Controller Longitude set to: " + vc.longitude
            .description)
        self.showViewController(vc, sender: vc)
    }
    
//    @IBAction func refresh(sender: AnyObject) {
//        refreshFunction()
//    }
    
    func refreshAction(sender: UIButton!) {
        refreshFunction()
    }
    
    func addPokemon(latitude: Double, longitude: Double, index: Int, timePosted: Float, postID: Int) {
        print("Report latitude: " + latitude.description)
        print("Report longitude: " + longitude.description)
        let pokemonName = nameData[index]
        let pokemon = CustomPointAnnotation()
        pokemon.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        pokemon.pinCustomImageName = (pokemonName as! String) + ".png"
        pokemon.latitude = latitude
        pokemon.longitude = longitude
        pokemon.title = pokemonName.capitalizedString
        pokemon.like = false
        pokemon.dislike = false
        pokemon.pinID = postID
        
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(timePosted))
        
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"
        
        let dateString = dayTimePeriodFormatter.stringFromDate(date)
        
        pokemon.subtitle = "Last Seen " + dateString
        let userLocation = CLLocation(latitude: userLat, longitude: userLon)
        let aLocation = CLLocation(latitude: latitude, longitude: longitude)
        pokemon.distance = Double(round(10 * (userLocation.distanceFromLocation(aLocation) * 0.000621371))/10)
        
        pokemon.timePosted = timePosted
        
        CLGeocoder().reverseGeocodeLocation(aLocation, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil
            {
                print("Geocode Error: " + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0
            {
                let pm = placemarks![0] as! CLPlacemark
                var address:String = ""
                if pm.thoroughfare != nil && pm.locality != nil {
                    address = pm.thoroughfare! + ", " + pm.locality!
                }
                pokemon.address = address
            }
        })
        
        self.mapView.addAnnotation(pokemon)
        
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
            anView!.leftCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            anView!.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        anView!.image = UIImage(named: cpa.pinCustomImageName)
        
        return anView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if popOut == false {
            selectedPokemon = view.annotation!.title!!.lowercaseString
            pokemonImage.image = UIImage(named: selectedPokemon)
            
            let cpa = view.annotation as? CustomPointAnnotation
            
            let id = cpa!.pinID
            let dictionary:NSMutableDictionary = NSMutableDictionary()
            Alamofire.request(.GET, "http://pokemongo-dev.us-west-1.elasticbeanstalk.com/api/reports/get", parameters: ["id" : id, "user_id" : getUserID()]).validate()
                .responseJSON{ (_, _, response) in
                    if let json = response.value {
                        let data = JSON(json)
                        print("alamofire body completed")
                        if data["success"] == 0 {
                            dictionary.setObject(0, forKey: "success")
                            dictionary.setObject(data["report"]["upvote"].intValue, forKey: "upvote")
                            dictionary.setObject(data["report"]["downvote"].intValue, forKey: "downvote")
                            dictionary.setObject(data["report"]["user"]["username"].stringValue, forKey: "username")
                            dictionary.setObject(data["report"]["voted"].intValue, forKey: "voted")
                            dictionary.setObject(data["report"]["user"]["rating"].intValue, forKey: "rating")
                            dictionary.setObject(data["report"]["timestamp"].floatValue, forKey: "time")
                        } else {
                            dictionary.setValue(1, forKey: "success")
                        }
                    } else {
                        dictionary.setValue(1, forKey: "success")
                    }
                    let success = dictionary["success"] as! Int
                    if success == 0 {
                        let username = dictionary["username"] as! String
                        let upvote = dictionary["upvote"] as! Int
                        let downvote = dictionary["downvote"] as! Int
                        self.canVote = dictionary["voted"] as! Int
                        let userRating = dictionary["rating"] as! Int
                        if username != "" {
                            self.user.text = "Submitted by " + username
                        } else {
                            self.user.text = "Submitted by Unknown"
                        }
                        self.postRate.text = "Current Rating: +" + String(upvote) + " -" + String(downvote)
                        self.userRate.text = "User's Current Rating: " + String(userRating)
                        
                        let currentTime = Float(NSDate().timeIntervalSince1970)
                        let timePosted = dictionary["time"] as! Float
                        let elapsedTime = (currentTime - timePosted)
                        var duration = Int(elapsedTime)
                        var timeMessage = ""
                        print(currentTime)
                        print(elapsedTime)
                        print(cpa!.timePosted)
                        if duration < 60 {
                            timeMessage = String(duration) + " second(s) ago"
                        }
                        else if duration >= 86400 {
                            duration = Int(duration / 86400)
                            timeMessage = String(duration) + " day(s) ago"
                        }
                        else if duration >= 3600 {
                            duration = Int(duration / 3600)
                            timeMessage = String(duration) + " hour(s) ago"
                        }
                        else {
                            duration = Int(duration / 60)
                            timeMessage = String(duration) + " minute(s) ago"
                        }
                        
                        self.time.text = timeMessage
                    }
                    
                    let xCoord = self.pop.frame.origin.x
                    let yCoord = self.pop.frame.maxY
                    let aHeight = self.pop.frame.size.height
                    let aWidth = self.pop.frame.size.width
                    
                    let buttonSize = CGSize(width: self.mapWidth / 7, height: self.mapWidth / 7)
                    self.likeButton.view = view
                    self.dislikeButton.view = view
                    
                    if cpa!.like == true || self.canVote == 1 {
                        self.likeButton.setImage(UIImage(named: "Thumbs Up highlight"), forState: UIControlState.Normal)
                    }
                    else {
                        self.likeButton.setImage(UIImage(named: "Thumbs Up"), forState: UIControlState.Normal)
                    }
                    
                    if cpa!.dislike == true || self.canVote == 2 {
                        self.dislikeButton.setImage(UIImage(named: "Thumbs Down highlight"), forState: UIControlState.Normal)
                    }
                    else {
                        self.dislikeButton.setImage(UIImage(named: "Thumbs Down"), forState: UIControlState.Normal)
                    }
                    
                    UIView.animateWithDuration(0.28, animations: {
                        self.pop.frame = CGRectMake(xCoord, yCoord, aWidth, aHeight)
                        self.shadow.alpha = 0.5
                    })
                    UIButton.animateWithDuration(0.28, animations: {
                        self.likeButton.frame = CGRect(x: self.mapWidth * 0.65, y: self.popUpHeight - (buttonSize.width / 2), width: buttonSize.width, height: buttonSize.height)
                        self.dislikeButton.frame = CGRect(x: self.likeButton.frame.maxX, y: self.popUpHeight - (buttonSize.width / 2), width: buttonSize.width, height: buttonSize.height)
                        
                    })
            }
            
            let userLocation = CLLocation(latitude: userLat, longitude: userLon)
            let aLocation = CLLocation(latitude: cpa!.latitude, longitude: cpa!.longitude)
            cpa!.distance = Double(round(10 * (userLocation.distanceFromLocation(aLocation) * 0.000621371))/10)
            let text = String(format: "%.1f", arguments:[cpa!.distance])
            distance.text = text + " miles away"
            
            if cpa!.address != nil {
                location.text = "at " + cpa!.address
            }
            else {
                location.text = ""
            }
        }
        popOut = true
    }
    
    func likeAction(sender: CustomButton!) {
        let cpa = sender.view.annotation as? CustomPointAnnotation
        let id = cpa!.pinID
        if canVote == 0 {
            if sender == likeButton {
                upvotePost(id, sender: sender, cpa: cpa!)
            }
            else {
                downvotePost(id, sender: sender, cpa: cpa!)
            }
        }
        print(canVote)
    }
    
    func refreshFunction() {
        let mapPoint = mapView.visibleMapRect
        let topLeftCoordinates = MKCoordinateForMapPoint(mapPoint.origin)
        let mapPointBottomRightX = MKMapRectGetMaxX(mapPoint)
        let mapPointBottomRightY = MKMapRectGetMaxY(mapPoint)
        let bottomRightCoordinates = MKCoordinateForMapPoint(MKMapPoint(x: mapPointBottomRightX, y: mapPointBottomRightY))
        self.mapView.removeAnnotations(self.mapView.annotations)
        Alamofire.request(.GET, "http://pokemongo-dev.us-west-1.elasticbeanstalk.com/api/reports/filter", parameters: ["top_left_latitude" : topLeftCoordinates.latitude, "top_left_longitude" : topLeftCoordinates.longitude, "bottom_right_latitude": bottomRightCoordinates.latitude, "bottom_right_longitude": bottomRightCoordinates.longitude]).validate()
            .responseJSON{ (_, _, response) in
                if let json = response.value {
                    let data = JSON(json)
                    if data["success"] == 0 {
                        let reports = data["reports"].arrayValue
                        for report in reports {
                            let latitude = report["latitude"].doubleValue
                            let longitude = report["longitude"].doubleValue
                            let pokemon = report["pokemon"].intValue
                            let time = report["timestamp"].floatValue
                            let id = report["id"].intValue
                            self.addPokemon(latitude, longitude: longitude, index: pokemon, timePosted: time, postID: id)
                        }
                    } else {
                        UIView.animateWithDuration(0.28, animations: {
                            self.error.hidden = false
                            self.error.frame = CGRectMake(0, 0, self.error.frame.width, self.error.frame.height)
                            self.error.label.text = "Failed to refresh."
                            let delay = 2.5 * Double(NSEC_PER_SEC)
                            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            dispatch_after(time, dispatch_get_main_queue()) {
                                UIView.animateWithDuration(0.28, animations: {
                                    self.error.frame = CGRectMake(0, -1 * self.error.frame.height, self.error.frame.width, self.error.frame.height)
                                })
                            }
                        })
                    }
                } else {
                    UIView.animateWithDuration(0.28, animations: {
                        self.error.hidden = false
                        self.error.frame = CGRectMake(0, 0, self.error.frame.width, self.error.frame.height)
                        self.error.label.text = "Failed to refresh."
                        let delay = 2.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            UIView.animateWithDuration(0.28, animations: {
                                self.error.frame = CGRectMake(0, -1 * self.error.frame.height, self.error.frame.width, self.error.frame.height)
                            })
                        }
                    })
                }
        }
    }
    
    func upvotePost(id: Int, sender: UIButton, cpa: CustomPointAnnotation) -> Bool {
        var succesful:Bool = false
        Alamofire.request(.GET, "http://pokemongo-dev.us-west-1.elasticbeanstalk.com/api/reports/upvote", parameters: ["id" : id, "user_id" : getUserID()]).validate()
            .responseJSON{ (_, _, response) in
                if let json = response.value {
                    let data = JSON(json)
                    if data["success"] == 0 {
                        succesful = true
                        sender.setImage(UIImage(named: "Thumbs Up highlight"), forState: UIControlState.Normal)
                        cpa.like = true
                    } else {
                        UIView.animateWithDuration(0.28, animations: {
                            self.error.hidden = false
                            self.error.frame = CGRectMake(0, 0, self.error.frame.width, self.error.frame.height)
                            self.error.label.text = "Failed to upvote post."
                            let delay = 2.5 * Double(NSEC_PER_SEC)
                            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            dispatch_after(time, dispatch_get_main_queue()) {
                                UIView.animateWithDuration(0.28, animations: {
                                    self.error.frame = CGRectMake(0, -1 * self.error.frame.height, self.error.frame.width, self.error.frame.height)
                                })
                            }
                        })
                    }
                } else {
                    UIView.animateWithDuration(0.28, animations: {
                        self.error.hidden = false
                        self.error.frame = CGRectMake(0, 0, self.error.frame.width, self.error.frame.height)
                        self.error.label.text = "Failed to upvote post."
                        let delay = 2.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            UIView.animateWithDuration(0.28, animations: {
                                self.error.frame = CGRectMake(0, -1 * self.error.frame.height, self.error.frame.width, self.error.frame.height)
                            })
                        }
                    })
                }
        }
        return succesful
    }
    
    func downvotePost(id: Int, sender: UIButton, cpa: CustomPointAnnotation) -> Bool {
        var succesful:Bool = false
        Alamofire.request(.GET, "http://pokemongo-dev.us-west-1.elasticbeanstalk.com/api/reports/downvote", parameters: ["id" : id, "user_id": getUserID()]).validate()
            .responseJSON{ (_, _, response) in
                if let json = response.value {
                    let data = JSON(json)
                    if data["success"] == 0 {
                        succesful = true
                        sender.setImage(UIImage(named: "Thumbs Down highlight"), forState: UIControlState.Normal)
                        cpa.dislike = true
                    } else {
                        UIView.animateWithDuration(0.28, animations: {
                            self.error.hidden = false
                            self.error.frame = CGRectMake(0, 0, self.error.frame.width, self.error.frame.height)
                            self.error.label.text = "Failed to downvote post."
                            let delay = 2.5 * Double(NSEC_PER_SEC)
                            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            dispatch_after(time, dispatch_get_main_queue()) {
                                UIView.animateWithDuration(0.28, animations: {
                                    self.error.frame = CGRectMake(0, -1 * self.error.frame.height, self.error.frame.width, self.error.frame.height)
                                })
                            }
                        })
                    }
                } else {
                    UIView.animateWithDuration(0.28, animations: {
                        self.error.hidden = false
                        self.error.frame = CGRectMake(0, 0, self.error.frame.width, self.error.frame.height)
                        self.error.label.text = "Failed to downvote post."
                        let delay = 2.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            UIView.animateWithDuration(0.28, animations: {
                                self.error.frame = CGRectMake(0, -1 * self.error.frame.height, self.error.frame.width, self.error.frame.height)
                            })
                        }
                    })
                }
        }
        return succesful
    }
    
    func removePopUp(tap: UITapGestureRecognizer) {
        var point = tap.locationInView(self.view)
        point = self.pop.convertPoint(point, fromView:self.view)
        let updatedBounds = CGRect(x: self.pop.bounds.minX, y: self.pop.bounds.minY, width: self.pop.bounds.width, height: self.pop.bounds.height + (likeButton.frame.height / 2))
        if !CGRectContainsPoint(updatedBounds, point) && popOut == true {
            let xCoord = pop.frame.origin.x
            let yCoord = 0 - pop.frame.maxY
            let aWidth = pop.frame.size.width
            let aHeight = pop.frame.size.height
            
            let buttonSize = CGSize(width: mapWidth / 7, height: mapWidth / 7)
            
            UIView.animateWithDuration(0.28, animations: {
                self.pop.frame = CGRectMake(xCoord, yCoord, aWidth, aHeight)
                self.shadow.alpha = 0
            })

            UIButton.animateWithDuration(0.28, animations: {
                self.likeButton.frame = CGRect(x: self.mapWidth * 0.65 + (buttonSize.width / 2), y: self.popUpHeight, width: 0, height: 0)
                self.dislikeButton.frame = CGRect(x: self.likeButton.frame.maxX + (buttonSize.width / 2), y: self.popUpHeight, width: 0, height: 0)
                
            })
            popOut = false
            
            
        }
        
    }
    
    func sendLocationToServer(location: CLLocation) {
        let defaults = NSUserDefaults()
        print("Users location updated to: (" + String(location.coordinate.longitude) + ", " + String(location.coordinate.latitude) + ")")
        Alamofire.request(.GET, "http://pokemongo-dev.us-west-1.elasticbeanstalk.com/api/notifications/send", parameters: ["user": defaults.stringForKey("user_id")!, "latitude": location.coordinate.latitude, "longitude" : location.coordinate.longitude]).validate().responseJSON { (_, _, response) in
            if let json = response.value {
                var data = JSON(json)
                var succesful = data["success"].stringValue
                if succesful == "1" {
                
                } else {
                    print("Location was sent to server")
                }
            } else {
                print("there was a network error while sending location to server")
            }
        }
    }
    
    func centerMap() {
        let location = locationManager.location?.coordinate
        let center = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: self.mapView.region.span.latitudeDelta, longitudeDelta: self.mapView.region.span.longitudeDelta))
        self.mapView.setRegion(region, animated: true)
    }
    
    func getUserID() -> String {
        let defaults = NSUserDefaults()
        return defaults.stringForKey("user_id")!
    }
    
}

extension UIColor{
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: NSScanner = NSScanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "#")
        // Scan hex value
        scanner.scanHexInt(&hexInt)
        return hexInt
    }
}


