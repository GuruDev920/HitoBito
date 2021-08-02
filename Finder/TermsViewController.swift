//
//  TermsViewController.swift
//  Finder
//
//  Created by djay mac on 03/02/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url:NSURL = NSURL(string: termsUrl)!
        let req:NSURLRequest = NSURLRequest(url: url as URL)
        webView.load(req as URLRequest)
        
    }

}
