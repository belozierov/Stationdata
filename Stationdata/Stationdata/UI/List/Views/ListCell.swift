//
//  ListCell.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

final class ListCell: UITableViewCell {
    
    private let stack = UIStackView()
    private let label = UILabel()
    private let button = UIButton(type: .system)
    private let arrow = UIImageView(image: #imageLiteral(resourceName: "Right-Arrow"))
    private let progressBar = ProgressBar()
    private let progressBarBackground = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //stackView
        stack.spacing = 16
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        let stackHeightConstraint = stack.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        stackHeightConstraint.priority = UILayoutPriorityDefaultHigh
        stackHeightConstraint.isActive = true
        
        //labelView
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        stack.addArrangedSubview(label)
        
        //button
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        
        //arrow
        arrow.contentMode = .center
        arrow.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        
        //progressBar
        progressBar.tintColor = #colorLiteral(red: 0.1450980392, green: 0.6, blue: 0.937254902, alpha: 1)
        progressBarBackground.translatesAutoresizingMaskIntoConstraints = false
        progressBarBackground.widthAnchor.constraint(equalToConstant: 20).isActive = true
        progressBarBackground.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.widthAnchor.constraint(equalToConstant: 20).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        progressBar.centerXAnchor.constraint(equalTo: progressBarBackground.centerXAnchor).isActive = true
        progressBar.centerYAnchor.constraint(equalTo: progressBarBackground.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buttonTapped() {
        buttonTappedCallback?()
    }
    
    var buttonTappedCallback: (() -> ())?
    
    var name: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    func config(with location: Location) {
        switch location.downloadState {
        case .notDownloaded:
            removeFromStack(arrow)
            removeFromStack(progressBarBackground)
            progressBar.stopAnimation()
            button.setTitle("Download".localized, for: .normal)
            stack.addArrangedSubview(button)
        case .downloaded:
            removeFromStack(button)
            removeFromStack(progressBarBackground)
            progressBar.stopAnimation()
            stack.addArrangedSubview(arrow)
        case .haveUpdate:
            removeFromStack(arrow)
            removeFromStack(progressBarBackground)
            progressBar.stopAnimation()
            button.setTitle("Update".localized, for: .normal)
            stack.addArrangedSubview(button)
        }
    }
    
    func animateDownloading() {
        for view in stack.arrangedSubviews where view !== label && view !== progressBar {
            removeFromStack(view)
        }
        stack.addArrangedSubview(progressBarBackground)
        progressBar.loading()
    }
    
    private func removeFromStack(_ view: UIView) {
        view.removeFromSuperview()
        stack.removeArrangedSubview(view)
    }
    
}
