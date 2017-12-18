//
//  HomeTableViewController.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 11/11/16.
//  Copyright © 2016 Kokpheng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import NVActivityIndicatorView
import SCLAlertView

class HomeTableViewController: UITableViewController, NVActivityIndicatorViewable {
    
    // Property
    var articles: [Article] = []
    var pagination: Pagination = Pagination()
    
    @IBOutlet weak var footerindicator: UIActivityIndicatorView!
    
    @IBOutlet weak var footerView: UIView!
    
    let service = ArticleService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        service.delegate = self
        
        // register class
        let nib = UINib(nibName: "TableViewSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 53
        
        // Add refresh control action
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        
        getData(pageNumber: 1)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showDetail" {
            let destView = segue.destination as! DetailTableViewController
            destView.articleID = sender as? String
        }else if segue.identifier == "showEdit"{
            let destView = segue.destination as! AddEditInfoTableViewController
            destView.article = sender as? Article
        }
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        getData(pageNumber: 1)
        
    }
    
    func getData(pageNumber : Int) {
        if self.pagination.page == 1 {
            // Create NVActivityIndicator
            let size = CGSize(width: 30, height:30)
            startAnimating(size, message: "Loading...", type: NVActivityIndicatorType.ballBeat)
        }
        
        service.getData(pageNumber: pageNumber)
    }
}


// MARK: - Table view data source
extension HomeTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.articles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        
        // Configure the cell...
        let article = self.articles[indexPath.section]
        cell.configureCellWithArticle(article)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: "\(self.articles[indexPath.section].id)")
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        let headerCell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeader") as! TableViewSectionHeader

        let article = self.articles[section]
        headerCell.configureCellwithTitle(article.author.name, dateTime: article.createdDate, imageUrl: article.author.imageUrl)
        
        return headerCell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            
            self.startAnimating()
            self.service.deleteArticle(with: "\(self.articles[indexPath.section].id)", completion: { error in
                self.stopAnimating()
                
                // check error
                if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }
                
                tableView.beginUpdates()
                self.articles.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                tableView.endUpdates()
                
            })
        }
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { action, index in
            self.performSegue(withIdentifier: "showEdit", sender: self.articles[indexPath.section])
        }
        
        edit.backgroundColor = UIColor.brown
        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // indicator stop loading
        if !self.footerindicator.isAnimating {
            // last cell > or = amount of users
            if indexPath.section + 1 >= self.articles.count {
                
                if self.pagination.page < self.pagination.totalPages {
                    self.footerView.isHidden = false
                    self.footerindicator.startAnimating()
                    getData(pageNumber: self.pagination.page + 1)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension HomeTableViewController: ArticleServiceDelegate {
    func didReceivedArticle(with articles: [Article]?, pagination: Pagination?, error: Error?) {
        self.stopAnimating()
        // hide footer and indicator
        self.footerView.isHidden = true
        self.footerindicator.stopAnimating()
        self.refreshControl?.endRefreshing()
        
        // check error
        if let error = error { SCLAlertView().showError("Error", subTitle: error.localizedDescription); return }
        
        self.pagination = pagination!
        
        // if current == 1 means first request, else append data
        if self.pagination.page == 1 {
            self.articles.removeAll()
            self.articles = articles!
        }else{
            self.articles.append(contentsOf: articles!)
        }
        
        self.tableView.reloadData()
    }
}
