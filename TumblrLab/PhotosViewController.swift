//
//  PhotosViewController.swift
//  TumblrLab
//
//  Created by Sanat Deshpande on 2/8/17.
//  Copyright © 2017 Sanat Deshpande. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var posts: [NSDictionary] = []
    var offset: Int = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var PhotoCell: UITableViewCell!
    var isMoreDataLoading = false
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.rowHeight = 240
        
        
        //Refresh data when pulled up
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        loadData(refreshControl: refreshControl)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        if (post.value(forKeyPath: "photos") as? [NSDictionary]) != nil {
            let photos = post.value(forKeyPath: "photos") as? [NSDictionary]
            let imageUrlString = photos?[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                cell.imageViewer.setImageWith(imageUrl)
            } else {
            }
            
        } else {
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhotoDetailsViewController
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        let post = posts[(indexPath?.row)!]
        
        tableView.deselectRow(at: indexPath!, animated: true)
        
        if (post.value(forKeyPath: "photos") as? [NSDictionary]) != nil {
            let photos = post.value(forKeyPath: "photos") as? [NSDictionary]
            let imageUrlString = photos?[0].value(forKeyPath: "original_size.url") as! String
            let imageUrl = URL(string: imageUrlString)
            vc.photoUrl = imageUrl
        }
    }
    
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadData(refreshControl: refreshControl)
        // Configure session so that completion handler is executed on main UI thread
        
    }
    
    func loadData(refreshControl: UIRefreshControl){
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(offset)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        
                        self.posts += responseFieldDictionary["posts"] as! [NSDictionary]
                        self.tableView.reloadData()
                        refreshControl.endRefreshing()
                        self.isMoreDataLoading = false
                        // This is where you will store the returned array of posts in your posts property
                        // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                    }
                }
        });
        task.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!isMoreDataLoading){
            
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                offset += 1
                loadData(refreshControl: refreshControl)
            }
        }
    }

   
}
