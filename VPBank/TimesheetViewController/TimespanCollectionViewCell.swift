//
//  TimespanCollectionViewCell.swift
//  VPBank
//
//  Created by Van Nguyen on 8/15/20.
//  Copyright © 2020 Van Nguyen. All rights reserved.
//

import UIKit

class TimespanCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lbTimespan: UILabel!
    
    func updateTimelineForRow(text: String?, forRow: Int) {
        if (forRow == 0) {
            lbTimespan.text = ""
        } else {
            lbTimespan.text = text
        }
        self.backgroundColor = .white
    }
}
