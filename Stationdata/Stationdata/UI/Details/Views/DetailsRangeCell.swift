//
//  DetailsRangeCell.swift
//  Stationdata
//
//  Created by Beloizerov on 25.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

final class DetailsRangeCell: UICollectionViewCell {
    
    private let topLabel = UILabel()
    private let middleLabel = UILabel()
    private let bottomLabel = UILabel()
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        
        //stackView
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.frame.origin = CGPoint(x: 0, y: 20)
        stackView.frame.size = CGSize(width: frame.width, height: frame.height - 55)
        contentView.addSubview(stackView)
        
        //labels
        configLabel(topLabel)
        configLabel(middleLabel)
        configLabel(bottomLabel)
        
        //line
        let line = CALayer()
        line.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        line.frame = CGRect(x: frame.width, y: 0, width: 0.5, height: stackView.frame.height)
        stackView.layer.addSublayer(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configLabel(_ label: UILabel) {
        label.textColor = #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1)
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        stackView.addArrangedSubview(label)
    }
    
    func setRange(_ range: DetailsManager.Ranges?) {
        topLabel.text = range?.upper
        middleLabel.text = range?.middle
        bottomLabel.text = range?.lower
    }
    
}

