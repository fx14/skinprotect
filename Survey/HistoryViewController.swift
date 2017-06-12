//
//  HistoryViewController.swift
//  Survey
//
//  Created by Charles Balachandran on 22/01/15.
//  Copyright (c) 2015 Charles Balachandran. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController {

    let transportItems = ["NIVEA Körperlotion","Nivea - shampoo"]
    let number = ["4005808702961","4005808815944"]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transportItems.count
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = false;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("HisotryCell") as! UITableViewCell
        cell.textLabel?.text = transportItems[indexPath.row];
        cell.detailTextLabel?.text = number[indexPath.row]        
        return cell
    }
}

