//
//  SystemCellValue1.swift
//  ZMusic
//
//  Created by lyxia on 2016/10/24.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit

struct SystemCellValue1Model {
    let imageName: String
    let text: String
    let detailText: String?
}

class SystemCellValue1: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.textLabel?.textColor = .white
        self.detailTextLabel?.textColor = .lightGray
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        self.selectedBackgroundView = bgView
    }
}
