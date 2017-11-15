//
//  MapVC.swift
//  PixelCityApp
//
//  Created by Boiko Artem on 03.11.17.
//  Copyright © 2017 Boiko Artem. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController,UIGestureRecognizerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var flowLAyout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    var popImageArray = [PopImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubletap()
        
//        registerForPreviewing(with: self, sourceView: collectionView!)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLAyout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullUpView.addSubview(collectionView!)
       
        
    }
    func addDoubletap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector (dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2) , y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2322467566, green: 0.2322531044, blue: 0.2322496772, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Helvetica Neue", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.2322467566, green: 0.2322531044, blue: 0.2322496772, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl(){
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    func animateViewUp(){
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown(){
        cancellAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: Actions
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9769095778, green: 0.7193570733, blue: 0.1747315228, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        //drop the pin on map
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancellAllSessions()
        
        imageUrlArray = []
        imageArray = []
        
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        //remove spinner and progress lbl
                        //reload collectionview
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin(){
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status:Bool) -> ()){
        Alamofire.request(FLICKR_URL(apiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                var popImage = PopImage()
                popImage.imageURL = FLICKR_POST_URL(farm: (photo["farm"]!), server: (photo["server"]!), id: (photo["id"]!), secret: (photo["secret"]!))
                popImage.title = photo["title"] as? String
                let userId = photo["owner"] as? String
                popImage.user = userId
                self.imageUrlArray.append(popImage.imageURL!)
                self.popImageArray.append(popImage)
                print(response)
            }
            handler(true)
            
        }
    }
    
    func retrieveImages(handler: @escaping(_ status: Bool) -> ()){
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count) Images downloaded"
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancellAllSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}



extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of items in array
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(passedData: popImageArray[indexPath.row], forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}

extension MapVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return nil}
        popVC.initData(passedData: popImageArray[indexPath.row], forImage: imageArray[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
