//
//  SiteViewController.swift
//  HiveMind
//
//  Created by Red Davis on 31/05/2015.
//  Copyright (c) 2015 Red Davis. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit

import SnapKit
import SwiftHTTP


class SiteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    private enum TableSection: Int
    {
        case Details, Technologies
    }
    
    private enum DetailsSectionRow: Int
    {
        case Domain, Country, Rank
    }
    
    // Private
    private let tableView = UITableView(frame: CGRect.zeroRect, style: .Grouped)
    private let loadingView = UIImageView(image: UIImage(named: "NavBarIcon"))
    private let errorLabel = UILabel()
    
    private var site: Site? {
        didSet
        {
            self.tableView.reloadData()
            
            self.navigationItem.rightBarButtonItem?.enabled = self.site != nil
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.None
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Title view
        let titleImageView = UIImageView(image: UIImage(named: "TextLogo"))
        self.navigationItem.titleView = titleImageView
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonTapped:")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareButtonTapped:")
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        // Table View
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.hidden = true
        self.view.addSubview(self.tableView)
        
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        // Loading view
        self.view.insertSubview(self.loadingView, belowSubview: self.tableView)
        
        self.loadingView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
        }
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.5
        pulseAnimation.toValue = NSNumber(float: 1.2);
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        pulseAnimation.autoreverses = true;
        pulseAnimation.repeatCount = FLT_MAX;
        self.loadingView.layer.addAnimation(pulseAnimation, forKey: nil)
        
        // Error label
        self.errorLabel.hidden = true
        self.view.addSubview(self.errorLabel)
        
        self.errorLabel.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
        }
        
        // Fetch extension item
        for item in self.extensionContext!.inputItems
        {
            let inputItem = item as! NSExtensionItem
            for provider in inputItem.attachments!
            {
                let itemProvider = provider as! NSItemProvider
                let propertyList = String(kUTTypePropertyList)
                
                if itemProvider.hasItemConformingToTypeIdentifier(propertyList)
                {
                    itemProvider.loadItemForTypeIdentifier(propertyList, options: nil, completionHandler: { (item, error) -> Void in
                        if let dictionary = item as? NSDictionary
                        {
                            let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                            let urlString = results["URL"] as! String
                            
                            if let URL = NSURL(string: urlString)
                            {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.fetchURLData(URL)
                                })
                            }
                        }
                    })
                }
                else
                {
                    NSLog("error")
                }
            }
        }
    }
    
    // MARK: -
    
    private func fetchURLData(URL: NSURL)
    {
        // Cleanup the website URL
        var websiteURLString = URL.host!
        websiteURLString = websiteURLString.stringByReplacingOccurrencesOfString(URL.scheme!, withString: "")
        websiteURLString = websiteURLString.stringByReplacingOccurrencesOfString("://", withString: "")
        
        let requestURLString = String(format: "http://api.askhivemind.com/sites/%@", websiteURLString)
        
        let request = HTTPTask()
        request.responseSerializer = JSONResponseSerializer()
        request.requestSerializer = HTTPRequestSerializer()
        request.requestSerializer.headers["Authorization"] = "hivemind-chrome" // Trolol
                
        request.GET(requestURLString, parameters: nil) { (response: HTTPResponse) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadingView.hidden = true
                
                if let error = response.error
                {
                    NSLog("error %@", error)
                }
                else if let JSON = response.responseObject as? Dictionary<String,AnyObject>
                {
                    NSLog("%@", JSON)
                    self.tableView.hidden = false
                    self.site = Site(dictionary: JSON)
                }
            })
        }
    }
    
    // MARK: Actions
    
    func doneButtonTapped(sender: AnyObject)
    {
        self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
    }
    
    func shareButtonTapped(sender: AnyObject)
    {
        if let siteDescription = self.site?.description
        {
            let activityViewController = UIActivityViewController(activityItems: [siteDescription], applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRows = 0
        if let site = self.site
        {
            switch TableSection(rawValue: section)!
            {
                case TableSection.Details:
                    numberOfRows = 3
                case TableSection.Technologies:
                    numberOfRows = site.technologies.count
            }
        }
        
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellIdentifier = "cellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        }
        
        if let tableSection = TableSection(rawValue: indexPath.section)
        {
            if tableSection == .Technologies
            {
                let technology = self.site?.technologies[indexPath.row]
                cell?.textLabel?.text = technology?.label
            }
            else if tableSection == .Details
            {
                if let detailRows = DetailsSectionRow(rawValue: indexPath.row)
                {
                    switch detailRows
                    {
                        case .Domain:
                            cell?.textLabel?.text = "Domain"
                            cell?.detailTextLabel?.text = self.site?.domain
                        case .Country:
                            cell?.textLabel?.text = "Country"
                            cell?.detailTextLabel?.text = self.site?.country
                        case .Rank:
                            cell?.textLabel?.text = "Rank"
                            cell?.detailTextLabel?.text = "\(self.site!.rank)"
                    }
                }
            }
        }
        
        return cell!
    }
    
    // MARK: UITableViewDelegate
}
