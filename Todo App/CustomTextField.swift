//
//  CustomTextField.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/2/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    var inset: CGFloat = 20

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        var placeholderColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
        attributedPlaceholder = NSAttributedString(string:self.placeholder!, attributes:
            [NSForegroundColorAttributeName: placeholderColor])
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        super.textRectForBounds(bounds)
        return CGRectInset(bounds, inset, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        super.editingRectForBounds(bounds)
        return CGRectInset(bounds, inset, 0)
    }
    
    
}
