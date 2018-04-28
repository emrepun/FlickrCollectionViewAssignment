//
//  ViewController.swift
//  Senfonico
//
//  Created by Emre HAVAN on 24.04.2018.
//  Copyright © 2018 Emre HAVAN. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    // Flickr API Settings
    let flickr_api_key = "acd810ba1b25a8400db16aece0142856"
    let flickr_url = "https://api.flickr.com/services/rest/"
    let search_method = "flickr.photos.search"
    let format_type = "json"
    let json_callback = 1
    let privacy_filter = 1
    
    // Localization Strings Declaration
    let searchTextFieldPlaceHolder = NSLocalizedString("searchTextFieldPlaceHolderText", comment: "")
    let connectionErrorTitle = NSLocalizedString("connectionErrorAlertTitle", comment: "")
    let connectionErrorMessage = NSLocalizedString("connectionErrorAlertMessage", comment: "")
    let unavailableTagErrorTitle = NSLocalizedString("unavailableTagAlertTitle", comment: "")
    let unavailableTagErrorMessage = NSLocalizedString("unavailableTagAlertMessage", comment: "")
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let searchTextField = UITextField(frame: CGRect(x: 16, y: 7, width: 240, height: 30))
    
    // Initialize an empty array which will be consists of Images to show.
    var imageArray = [Image]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.placeholder = searchTextFieldPlaceHolder
        searchTextField.delegate = self
        configureActivityIndicator()
        configureToolbarItems()
        setTagAndStartConnection()
    }
    
    // MARK: Configurations
    func toolBarItems() -> [UIBarButtonItem] {
        let textFieldButton = UIBarButtonItem(customView: searchTextField)
        searchTextField.keyboardType = .webSearch
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(setTagAndStartConnection))
        
        return [textFieldButton, space, search]
    }
    
    func configureToolbarItems() {
        toolBar.items = toolBarItems()
    }
    
    func configureActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    @objc func setTagAndStartConnection() {
        if let tag = searchTextField.text, (searchTextField.text?.count)! > 0 {
            displayImage(tag: tag)
        } else {
            displayImage(tag: "flower")
        }
        
        keyboardShouldHide()
    }
    
    // MARK: Establishing Connection
    func displayImage(tag: String) {
        let parameters: Parameters = [
            "method": search_method,
            "api_key": flickr_api_key,
            "tags": tag,
            "privacy_filter": privacy_filter,
            "format": format_type,
            "nojsoncallback": json_callback
        ]
        
        // Make sure the array is empty before we make the connection to avoid showing images from
        // previous calls.
        imageArray.removeAll()
        collectionView.reloadData()
        activityIndicator.startAnimating()
 
        Alamofire.request(flickr_url, method: .get, parameters: parameters).responseJSON { [weak self] response in
            switch response.result {
            case .success(let value):
                print("success")
                let json = JSON(value)
                
                // Running through 20 Objects, since the amount of objects was not specified in the
                // assignment
                // Honestly I do not know yet to implement fetching more images as user scrolls down
                for index in 0..<20 {
                    let myFetchedPhoto = Image(userJson: json, index: index)
                    
                    let farm = myFetchedPhoto.farm
                    let server = myFetchedPhoto.server
                    let photoID = myFetchedPhoto.id
                    let secret = myFetchedPhoto.secret
                    
                    myFetchedPhoto.imageString = "http://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_n.jpg/"
                    
                    self?.imageArray.append(myFetchedPhoto)
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.reloadData()
                }
                
                print("success for real")
                
            case .failure(let error):
                print(error.localizedDescription)
                self?.activityIndicator.stopAnimating()
                self?.showAlert(title: (self?.connectionErrorTitle)!, message: (self?.connectionErrorMessage)!)
            }
        }
    }
    
    // MARK: Collection View Settings
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ImageCell
        
        let urlString = imageArray[indexPath.row].imageString
        let imageURL = URL(string: urlString)
        
        if let imageData = NSData(contentsOf: imageURL!) {
            cell.imageView.image = UIImage(data: imageData as Data)
        } else {
            cell.imageView.image = #imageLiteral(resourceName: "placeholder-image")
            self.showAlert(title: unavailableTagErrorTitle, message: unavailableTagErrorMessage)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlString = imageArray[indexPath.row].imageString
        loadLargerImage(with: urlString)
    }
    
    // MARK: Large Image Settings
    func loadLargerImage(with urlString: String) {
        let imageURL = URL(string: urlString)
        var image = UIImage()
        if let imageData = NSData(contentsOf: imageURL!) {
            image = UIImage(data: imageData as Data)!
        } else {
            image = #imageLiteral(resourceName: "placeholder-image")
        }
        
        let imageView = UIImageView(image: image)
        imageView.frame = self.view.frame
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        imageView.addGestureRecognizer(tap)
        
        self.view.addSubview(imageView)
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    // MARK: Keyboard configurations
    func keyboardShouldHide() {
        searchTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        setTagAndStartConnection()
        return false
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertCompletionTitle", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
