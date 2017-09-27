//
//  SettingsContainer.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/22/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

class SettingsContainer: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let shareItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close(_:)))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        self.title = NSLocalizedString("GTField Settings", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
}
