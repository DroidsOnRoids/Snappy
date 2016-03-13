//
//  ImagesViewController.swift
//  Snappy
//
//  Created by Lukasz Mroz on 13.03.2016.
//  Copyright © 2016 Droids On Roids. All rights reserved.
//

import UIKit

let imageCellIdentifier = "imageCellIdentifier"

class ImagesViewController: UITableViewController {
    
    var images = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadSetup()
    }
    
    func viewDidLoadSetup() {
        pullToRefreshSetup()
        refreshImages()
        layoutSetup()
    }
    
    func layoutSetup() {
    
        tableView.contentInset = UIEdgeInsets(top: 20.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0)
    }
    
    func pullToRefreshSetup() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.whiteColor()
        refreshControl?.tintColor = UIColor.blackColor()
        refreshControl?.addTarget(self,
            action: Selector("refreshImages"),
            forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refreshImages() {
        // Every time we open the controller, reload images list
        SnapchatAPI.getImages { [weak self] result in
            // If we correctly did fetch the images
            guard case .Success(let response) = result else { return }
            
            // Now make sure the response is an array of dicts
            guard let imageArray = response["images"] as? [[String: AnyObject]] else { return }
            
            // Instantiate new array that will be our data source
            var newImages = [String]()
            
            // Now iterate over the array of dicts
            for imageDict in imageArray {
                // Get imageURL for current dict
                if let imageURL = imageDict["url"] as? String {
                    newImages.append(imageURL)
                }
            }
            
            // Replace our current data source with the new one
            self?.images = newImages
            
            // Close pull to refresh
            self?.refreshControl?.endRefreshing()
            
            // Reload our table
            self?.tableView.reloadData()
        }
    }
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(imageCellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = images[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
}