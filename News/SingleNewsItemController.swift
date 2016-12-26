//
//  SingleNewsItemController.swift
//  News
//
//  Created by Simo on 14.12.16.
//  Copyright © 2016 Simo. All rights reserved.
//

import UIKit
import HidingNavigationBar
import SwiftSoup
import Player

class SingleNewsItemController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var hidingNavBarManager: HidingNavigationBarManager?
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var linkToDownload = ""
    var currentNewsItemImage = UIImageView()
    var pubDate = ""
    var currentNewsItemTitle = ""
    var isVideo = Bool()
    
    struct SingleNewsItem {
        var category = String()
        var subCategory = String()
        var views = String()
        var thumbsUp = String()
        var thumbsDown = String()
        var newsItemText = String()
        var videoLink = String()
    }
    
    var singleItem = SingleNewsItem()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidingNavBarManager?.viewWillAppear(animated)
        spinner.startAnimating()
        
        let charset = "Видео"
        
        if self.currentNewsItemTitle.range(of: charset) != nil {
            isVideo = true
            print(self.isVideo.description)
            print("video")
            
        } else {
            print("no video")
            print(self.isVideo.description)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hidingNavBarManager?.viewWillDisappear(animated)
        
    }
    
    func parseHTML(link: String){
        
        let request = URLRequest(url: URL(string: link)!)
        let session = URLSession.shared
        
        session.dataTask(with: request, completionHandler: {data, response, error in
            
            DispatchQueue.main.async {
                if data != nil {
                    
                    do{
                        
                        let html = String(data: data!, encoding: .utf8)
                        let doc: Document = try SwiftSoup.parse(html!)
                        
                        let category: String = try doc.select("a.bar__link").first()!.text()
                        
                        let subCategory: String = try doc.select("a.bar__link").last()!.text()
                        
                        let seen: String = try doc.select("span.seen").first()!.text()
                        
                        let thumbUp: String = try doc.select("span.karma_plus").text()
                        
                        let thumbDown: String = try doc.select("span.karma_minus").text()
                        
                        let texts: Elements = try doc.select("div#item-news-canvas").select("div.text").select("p")
                        var texter = [String]()
                        for text: Element in texts.array() {
                            let txt = try "\(text.text())\n"
                            texter.append(txt)
                        }
                        
                        var videoLink = String()
                        
                        if self.isVideo {
                            videoLink = try doc.select("div#item-news-canvas").select("div.text").select("iframe").attr("src")
                        } else {
                            videoLink = ""
                        }
                        
                        let item = SingleNewsItem(category: category, subCategory: subCategory, views: seen, thumbsUp: thumbUp, thumbsDown: thumbDown, newsItemText: texter.joined(separator: "\n"), videoLink: videoLink)
                        
                        self.singleItem = item
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                        print(self.singleItem)
                        
                        self.title = item.subCategory
                        self.navigationItem.prompt = item.category
                        self.spinner.stopAnimating()
                        self.spinner.removeFromSuperview()
                        
                    } catch {
                        print(error)
                    }
                } else {
                    print("error is: \(error)")
                }
            }
        }).resume()
    }
    
    //// TableView datasoure and delegate
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
        hidingNavBarManager?.expansionResistance = 300
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 335
        
        parseHTML(link: linkToDownload)
        tableView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleNewsItemCell", for: indexPath) as! SingleNewsItemCell
        
        cell.currentNewsItemImage.image = currentNewsItemImage.image
        cell.currentNewsItemTitle.text = currentNewsItemTitle
        cell.currentNewsItemDescription.text = singleItem.newsItemText
        cell.pubDateLabel.text = pubDate
        cell.views.text = singleItem.views
        cell.thumbUp.text = singleItem.thumbsUp
        cell.thumbDown.text = singleItem.thumbsDown
        
        if let wv = cell.webViewVideo {
            if isVideo == false {
                wv.removeFromSuperview()
            } else if isVideo{
                
                //cell.webViewVideo.loadRequest(URLRequest(url: URL(string: self.singleItem.videoLink)!))
               
            }
        }
        
        return cell
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
