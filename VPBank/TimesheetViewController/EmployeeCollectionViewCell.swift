//
//  EmployeeCollectionViewCell.swift
//  VPBank
//
//  Created by Van Nguyen on 8/15/20.
//  Copyright © 2020 Van Nguyen. All rights reserved.
//

import UIKit

class EmployeeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    
    func updateEmployee(name: String, color: String, taskCount: Int) {
        backgroundColor = UIColor(hex: color)
        lbName.text = name
        lbDescription.text = "(\(taskCount))"
    }
}
