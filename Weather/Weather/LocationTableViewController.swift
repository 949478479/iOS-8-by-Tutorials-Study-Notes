//
//  LocationTableViewController.swift
//  Weather
//
//  Created by Joyce Echessa on 10/18/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
    
    var selectedLocation: Location = .MyLocation
    
    func refresh() {
        for i in 0..<Location.NumLocationTypes.rawValue {
            let cell = tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: i, inSection: 0))
            cell.accessoryType = selectedLocation.rawValue == i ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        refresh()
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath)
        cell.accessoryType = (selectedLocation.rawValue == i ? .Checkmark : .None)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedLocation = Location(rawValue: indexPath.row)!
        refresh()
    }
    
    //Redmond, WA 51.461231,-0.9259415
    //Menlo Park, CA 37.484765,-122.148549
    //Mountain View, CA 37.422,-122.084058
    
}

enum Location: Int {
    case MicrosoftHQ
    case FacebookHQ
    case GoogleHQ
    case MyLocation
    case NumLocationTypes
}
