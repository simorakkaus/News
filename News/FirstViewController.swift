//
//  FirstViewController.swift
//  News
//
//  Created by Simo on 28.11.16.
//  Copyright © 2016 Simo. All rights reserved.
//

import UIKit
import SWXMLHash
import HidingNavigationBar




class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainSpinner: UIActivityIndicatorView!
    
    let allNewsURL = "http://www.rzn.info/rss/news/all.xml"
    var linkToDownload = String()
    
    var hidingNavBarManager: HidingNavigationBarManager?
    
    struct NewsItem {
        var ttl, descr, pubDate, link : String
        var img : UIImageView
    }
    var newsItems = [NewsItem]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FirstViewController.handleRefresh), for: UIControlEvents.valueChanged)
        
        refreshControl.tintColor = UIColor(red:0.96, green:0.60, blue:0.22, alpha:1.0)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        //refreshControl.beginRefreshing()
        loadData()
        //self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hidingNavBarManager?.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    //// TableView datasoure and delegate
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        
        mainSpinner.isHidden = false
        mainSpinner.startAnimating()
        
        loadData()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175
        
        self.tableView.addSubview(self.refreshControl)
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
        hidingNavBarManager?.expansionResistance = 100
        
        
//        if let tabBar = navigationController?.tabBarController?.tabBar {
//            hidingNavBarManager?.manageBottomBar(tabBar)
//        }
        
        hidingNavBarManager?.refreshControl = refreshControl
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsItemCell", for: indexPath) as! NewsItemCell
        
        cell.itemTitle.text = self.newsItems[indexPath.row].ttl
        cell.itemTitle.text = cell.itemTitle.text?.uppercased()
        cell.itemTitle.sizeToFit()
        
        cell.itemDescription.text = self.newsItems[indexPath.row].descr
        cell.itemDescription.sizeToFit()
        
        cell.itemPubDate.text = self.newsItems[indexPath.row].pubDate
        
        cell.itemImage.image = self.newsItems[indexPath.row].img.image
        
        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        
        cell.selectionStyle = .none
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.linkToDownload = newsItems[indexPath.row].descr
//        
//        self.performSegue(withIdentifier: "toNewsItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toNewsItem" {
            let vc = segue.destination as! SingleNewsItemController
            
            let linkToDownload = newsItems[(self.tableView.indexPathForSelectedRow?.row)!].link
            let currentNewsItemImage = newsItems[(self.tableView.indexPathForSelectedRow?.row)!].img
            let pubDate = newsItems[(self.tableView.indexPathForSelectedRow?.row)!].pubDate
            let currentNewsItemTitle = newsItems[(self.tableView.indexPathForSelectedRow?.row)!].ttl
            
            vc.linkToDownload = linkToDownload
            vc.currentNewsItemImage = currentNewsItemImage
            vc.pubDate = pubDate
            vc.currentNewsItemTitle = currentNewsItemTitle
        }
    }
    
    func refreshUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadData() {
        //newsItems.removeAll()
        
        let request = URLRequest(url: URL(string: allNewsURL)!)
        let session = URLSession.shared
        
        session.dataTask(with: request, completionHandler: {data, response, error in
            
            DispatchQueue.main.async {
                if data != nil {
                    self.mainSpinner.stopAnimating()
                    self.mainSpinner.isHidden = true
                }
            }
            
            if data != nil {
                DispatchQueue.main.async {
                    
                    self.newsItems.removeAll()
                    
                    let xml = SWXMLHash.parse(data!)
                    
                    for element in xml["rss"]["channel"]["item"] {
                        let title = element["title"].element?.text
                        let description = element["description"].element?.text
                        let pubDate = self.convertPubDate(pubDate: (element["pubDate"].element?.text)!)
                        let link = element["link"].element?.text
                        let img = self.loadImageFromURL(URL(string: element["enclosure"].element!.attribute(by: "url")!.text)!)
                        
                        let item = NewsItem(ttl: title!, descr: description!, pubDate: pubDate, link: link!, img: img)
                        
                        self.newsItems.append(item)
                        self.tableView.reloadData()
                    }
                    
                    self.tableView.isHidden = false
                    self.refreshControl.endRefreshing()
                }
            } else {
                print(error!.localizedDescription)
            }
            
            
        }).resume()
    }
    
    func loadImageFromURL(_ URL: Foundation.URL) -> UIImageView {
        let request = URLRequest(url: URL)
        let session = URLSession.shared
        let img = UIImageView()
        
        session.dataTask(with: request, completionHandler: {data, response, error in
            if let imageData = data {
                img.image = UIImage(data: imageData)!
                self.refreshUI()
            } else {
                print(error!)
            }
        }).resume()
        
        return img
    }
    
    func convertPubDate(pubDate: String) -> String {
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en_US")
        formatter.locale = locale
        formatter.dateFormat = "ee, dd MMM yyyy HH:mm:ss zzzz"
        
        let date = formatter.date(from: pubDate)
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd.MM.yyyy HH:mm"
        
        let pubDateString = formatter2.string(from: date!)
        
        return pubDateString
    }
}
