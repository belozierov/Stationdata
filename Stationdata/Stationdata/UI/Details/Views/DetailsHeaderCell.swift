//
//  DetailsHeaderCell.swift
//  Stationdata
//
//  Created by Beloizerov on 24.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

final class DetailsHeaderCell: UICollectionViewCell {
    
    private let labelView = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //labelView
        contentView.addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        labelView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8).isActive = true
        labelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        labelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var label: String? {
        get { return labelView.text }
        set { labelView.text = newValue }
    }
    
}
