//
//  IconKidsViewController.swift
//  Conventions
//
//  Created by Bahat, David on 03/09/2018.
//  Copyright © 2018 Amai. All rights reserved.
//

import Foundation

class WebContentViewController: BaseViewController {
    
    @IBOutlet private weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        guard
            let resourcePath = Bundle.main.resourcePath,
            let webContent = try? String(contentsOfFile: resourcePath + getWebPageName()) else {
                return
        }
        
        contentTextView.attributedText = webContent.htmlAttributedString()
    }
    
    func getWebPageName() -> String {
        return ""
    }
}

class DiscountsViewController: WebContentViewController {
    override func getWebPageName() -> String {
        return "/DiscountsContent.html"
    }
}

class AccessabilityViewController: WebContentViewController {
    override func getWebPageName() -> String {
        return "/AccessabilityContent.html"
    }
}
