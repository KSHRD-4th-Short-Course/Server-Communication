//
//  HomeTableViewCell.swift
//  ServerCommunication
//
//  Created by Kokpheng on 11/10/16.
//  Copyright © 2016 Kokpheng. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var readMoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Border radius
        readMoreLabel.layer.cornerRadius = readMoreLabel.layer.frame.height / 2
        readMoreLabel.layer.masksToBounds = true
        
        coverImageView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCellWithArticle(_ article: Article) {
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        coverImageView.kf.setImage(with: URL(string: article.imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholder: UIImage(named: "noimage_thumbnail"))
    }
}
