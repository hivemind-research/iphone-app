//
//  Site.swift
//  HiveMind
//
//  Created by Red Davis on 31/05/2015.
//  Copyright (c) 2015 Red Davis. All rights reserved.
//

import Foundation


public struct Site
{
    public let domain: String
    public let country: String
    public let rank: Int
    public let technologies: [Technology]
    
    public init(dictionary: Dictionary<String,AnyObject>)
    {
        let data = dictionary["data"] as! Dictionary<String,AnyObject>
        
        self.domain = data["domain"] as! String
        self.country = data["country"] as! String
        self.rank = data["rank"] as! Int
        
        var technologies = [Technology]()
        
        let technologyDictionaries = data["technologies"] as! Array<Dictionary<String, AnyObject>>
        for technologyDictionary in technologyDictionaries
        {
            let technology = Technology(dictionary: technologyDictionary)
            technologies.append(technology)
        }
        
        self.technologies = technologies
    }
    
    public var description: String {
        var description = "Domain: \(self.domain)\n"
        description += "Country: \(self.country)\n"
        description += "Rank: \(self.rank)\n\n"
        description += "Technologies:\n"
        
        for technology in self.technologies
        {
            description += "\(technology.label)\n"
        }
        
        return description
    }
}


public struct Technology
{
    public let code: String
    public let label: String
    public let group: String
    public let groupLabel: String
    
    public init(dictionary: Dictionary<String, AnyObject>)
    {
        self.code = dictionary["code"] as! String
        self.label = dictionary["label"] as! String
        self.group = dictionary["group"] as! String
        self.groupLabel = dictionary["group_label"] as! String
    }
}
