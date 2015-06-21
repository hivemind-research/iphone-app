//
//  ActionViewController.swift
//  HivemineActionExtension
//
//  Created by Red Davis on 31/05/2015.
//  Copyright (c) 2015 Red Davis. All rights reserved.
//

import UIKit


@objc(RootActionViewController)


class RootActionViewController: UIViewController
{
    private let rootNavigationController: UINavigationController
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder)
    {
        self.rootNavigationController = UINavigationController()
        super.init(coder: aDecoder)
    }
    
    init()
    {
        let siteViewController = SiteViewController()
        self.rootNavigationController = UINavigationController(rootViewController: siteViewController)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.addChildViewController(self.rootNavigationController)
        self.view.addSubview(self.rootNavigationController.view)
        
        self.rootNavigationController.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
