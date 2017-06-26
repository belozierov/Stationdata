//
//  ProgressBar.swift
//  Stationdata
//
//  Created by Beloizerov on 25.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

final class ProgressBar: UIView {
    
    // MARK: - UIView
    
    override var tintColor: UIColor! {
        didSet {
            circle?.strokeColor = tintColor.cgColor
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                if animation { loading() }
            } else if bounds.origin != oldValue.origin {
                circle?.position = CGPoint()
            }
        }
    }
    
    // MARK: - Animation
    
    private var circle: CAShapeLayer?
    
    func loading() {
        stopAnimation()
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(center.x, center.y)
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 1.8 * .pi, clockwise: true).cgPath
        if circle == nil {
            circle = CAShapeLayer()
            circle!.fillColor = UIColor.clear.cgColor
            circle!.strokeColor = tintColor.cgColor
            circle!.lineWidth = 0.5
            layer.addSublayer(circle!)
        }
        circle?.path = circlePath
        animation = true
        rotateAnimation()
    }
    
    func stopAnimation() {
        animation = false
        layer.removeAllAnimations()
        transform = .identity
    }
    
    private var animation = false
    
    private func rotateAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear, .beginFromCurrentState], animations: {
            self.transform = self.transform.rotated(by: .pi / 2)
        }, completion: {
            if $0 { if self.animation { self.rotateAnimation() } else { self.transform = .identity } }
        })
    }
    
}
