//
//  DetailTableViewController.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 11/15/16.
//  Copyright © 2016 Kokpheng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import NVActivityIndicatorView
import SCLAlertView

class DetailTableViewController: UITableViewController, NVActivityIndicatorViewable {
    
    // Outlet
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var coverImageViewHeight: NSLayoutConstraint!
    
    // Property
    var articleID : String?
    let service = ArticleService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        service.delegate = self
        
        // Create NVActivityIndicator
        let size = CGSize(width: 30, height:30)
        startAnimating(size, message: "Loading...", type: NVActivityIndicatorType.ballBeat)
        
        // if have book id request data
        if let id = articleID {
            service.getArticle(by: id)
        }
        
        setupCell()
    }
    
    func setupCell() {
        self.categoryButton.backgroundColor = #colorLiteral(red: 0.4236315489, green: 0.4478745461, blue: 0.788145721, alpha: 1)
        self.categoryButton.layer.cornerRadius = categoryButton.layer.frame.height / 2
        self.categoryButton.layer.masksToBounds = true
        
        if let image = coverImageView.image {
            // Calculate aspect
            let aspect = image.size.height / image.size.width
            self.coverImageViewHeight.constant = self.view.frame.size.width * aspect
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension DetailTableViewController: ArticleServiceDelegate {
    func didReceivedArticle(with article: Article?, error: Error?) {
        self.stopAnimating()
        
        // check error
        if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }
        
        guard let article = article else { return }
        
        self.titleLabel.text = article.title
        self.descriptionLabel.text = article.description
        
        let categoryName = article.category.name
        self.categoryButton.setTitle("     \(categoryName)     ", for: .normal)
        self.navigationItem.title = categoryName
        
        self.coverImageView.kf.setImage(with: URL(string: article.imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholder: UIImage(named: "noimage_thumbnail")) { image, _, _, _ in
            
            if let image = image {
                // Calculate aspect
                let aspect = image.size.height / image.size.width
                self.coverImageViewHeight.constant = self.view.frame.size.width * aspect
            }
        }
        
        self.tableView.reloadData()
    }
}
