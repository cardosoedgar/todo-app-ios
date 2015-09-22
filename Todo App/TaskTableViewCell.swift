//
//  TaskTableViewCell.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/16/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    
    func markAsDone() {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: labelName.text!)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        
        labelName.attributedText = attributeString
    }
    
    func markAsUndone() {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: labelName.text!)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 0, range: NSMakeRange(0, attributeString.length))
        
        labelName.attributedText = attributeString
    }
}
