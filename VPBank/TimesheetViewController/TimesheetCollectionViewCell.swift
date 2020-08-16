//
//  TimesheetCollectionViewCell.swift
//  VPBank
//
//  Created by Van Nguyen on 8/15/20.
//  Copyright © 2020 Van Nguyen. All rights reserved.
//

import UIKit

class TimesheetCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    
    func updateTask(task: MTask?, color: String) {
        if task != nil {
            lbTitle.text = "#\(task!.id)"
            lbDescription.text = task?.name
            backgroundColor = UIColor(hex: color, alpha: 0.5)
        } else {
            lbTitle.text = ""
            lbDescription.text = ""
            backgroundColor = UIColor(hex: color, alpha: 0.2)
        }
    }
    
}
