//
//  DisablPasteTF.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 4/28/20.
//  Copyright © 2020 Mohamed Hafez. All rights reserved.
//

import UIKit

class DisablPasteTF: UITextField {

    override func caretRect(for position: UITextPosition) -> CGRect {
        
        return CGRect.zero
    }
}

