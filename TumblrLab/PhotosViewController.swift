//
//  PhotosViewController.swift
//  TumblrLab
//
//  Created by Sanat Deshpande on 2/8/17.
//  Copyright © 2017 Sanat Deshpande. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var posts: [NSDictionary]?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var PhotoCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.rowHeight = 240
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
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
                        self.posts = responseFieldDictionary["posts"] as? [NSDictionary]
                        self.tableView.reloadData()
                        
                        // This is where you will store the returned array of posts in your posts property
                        // self.feeds = responseFieldDictionary["posts"] as! [NSDictionary]
                    }
                }
        });
        task.resume()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let posts = posts {
            return posts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts?[indexPath.row]
        if (post?.value(forKeyPath: "photos") as? [NSDictionary]) != nil {
            let photos = post?.value(forKeyPath: "photos") as? [NSDictionary]
            let imageUrlString = photos?[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                cell.imageViewer.setImageWith(imageUrl)
            } else {
            }
            
        } else {
        }
        
        return cell
    }


   
}