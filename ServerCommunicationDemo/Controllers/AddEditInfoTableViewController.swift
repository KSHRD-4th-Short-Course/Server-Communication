//
//  AddEditInfoTableViewController.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 11/10/16.
//  Copyright © 2016 Kokpheng. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import NVActivityIndicatorView
import SCLAlertView

class AddEditInfoTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {
    
    // Property
    var article : Article?
    let imagePicker = UIImagePickerController()
    
    // Outlet
    @IBOutlet var descriptionLabel: UITextField!
    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var articleImageView: UIImageView!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    let service = ArticleService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if book is not nil, assign value to outlet
        if let article = article{
            titleLabel.text = article.title
            descriptionLabel.text = article.description
            articleImageView.kf.setImage(with: URL(string: article.imageUrl), placeholder: UIImage(named: "noimage_thumbnail"))
        }
        
        // set delegate for imagePicker
        imagePicker.delegate = self
        
        service.delegate = self
    }
    
    // TODO: Save Action
    @IBAction func save(_ sender: Any) {
        
        // Create NVActivityIndicator
        let size = CGSize(width: 30, height:30)
        startAnimating(size, message: "Loading...", type: NVActivityIndicatorType.ballBeat)
        
        service.uploadFile(file: UIImageJPEGRepresentation(self.articleImageView.image!, 1)!) { (fileUrl, error) in
            
            if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }

            var authorId = 0
            
            if let UserID = UserDefaults.standard.string(forKey: "UserID") {
                authorId = Int(UserID) ?? 0
            }
            
            let paramaters = [
                "title": self.titleLabel.text!,
                "description": self.descriptionLabel.text!,
                "author_id": authorId, // load user id from user default
                "category_id": self.categorySegment.selectedSegmentIndex + 1,
                "status": "1",
                "image": fileUrl ?? ""
                ] as [String : Any]
            
            // if have article data > update
            if let article = self.article  {
                self.service.updateArticle(with: "\(article.id)", paramaters: paramaters)
            }else {
                self.service.addArticle(paramaters: paramaters)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddEditInfoTableViewController {
    
    // TODO: Browse Image IBAction
    @IBAction func browseImage(_ sender: Any) {
        // coonfig property
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        // show image picker
        present(imagePicker, animated: true, completion: nil)
    }
    
    // TODO: Finish Picking Media
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        // Get image
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            // config property and assign image
            articleImageView.contentMode = .scaleAspectFit
            articleImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // TODO: Image Picker Controller Did Cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // TODO: Take Photo
    @IBAction func openCameraButton(sender: AnyObject) {
        // config property
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // TODO: Image Picker Did Finish Picking Image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // Set image to articleImageView
        articleImageView.image = image
        self.dismiss(animated: true, completion: nil);
    }
    
}

extension AddEditInfoTableViewController: ArticleServiceDelegate {
    func didAddedArticle(error: Error?) {
        if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }
        
        // show other NVActivityIndicator
        self.stopAnimating()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func didUpdatedArticle(error: Error?) {
        if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }
        
        // show other NVActivityIndicator
        self.stopAnimating()
        _ = self.navigationController?.popViewController(animated: true)
    }
}
