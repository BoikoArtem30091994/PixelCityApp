//
//  PopVC.swift
//  PixelCityApp
//
//  Created by Boiko Artem on 09.11.17.
//  Copyright © 2017 Boiko Artem. All rights reserved.
//

import UIKit
import Alamofire

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var imageTitleLbl: UILabel!
    @IBOutlet weak var buttomView: UIView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var photoTimeLbl: UILabel!
    
    
    var passedImage: UIImage!
    var passedData: PopImage!
    
    func initData(passedData data: PopImage ,forImage image: UIImage) {
        self.passedImage = image
        self.passedData = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTap()
        imageTitleLbl.text = passedData.title!
        addBlurEffect(view: buttomView, style: .light)
        retriveUser(userId: passedData.user!)
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Add tap gesture recognizer
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector (screenWasDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTap(){
    dismiss(animated: true, completion: nil)
    }
    //    MARK: Actions
    @IBAction func closeBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //JSON request
    func retriveUser(userId: String) {
        Alamofire.request(FLICKR_GET_USER_ID(userId: userId)).responseJSON { (responce) in
//          print(responce)
            guard let json = responce.result.value as? Dictionary <String, AnyObject> else {return}
            let personDict = json["person"] as! Dictionary<String, AnyObject>
            let usernameDict = personDict["username"] as! Dictionary<String, AnyObject>
            var username = (usernameDict["_content"] as? String)!
            
            self.usernameLbl.text = "\(username)"
        }
    }
    
    
    //Set blur effect for view
    
    func addBlurEffect(view: UIView, style: UIBlurEffectStyle) {
        
        view.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.insertSubview(blurEffectView, at: 0)
        
    }
}
