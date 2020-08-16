//
//  ViewController.swift
//  VPBank
//
//  Created by Van Nguyen on 8/14/20.
//  Copyright © 2020 Van Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ivLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "VPBank"
        
        // Feed data
        print(Session.shared)
        
        // Border radius
        ivLogo.layer.cornerRadius = 30.0
    }

    @IBAction func goToTimesheet(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "TimesheetViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

