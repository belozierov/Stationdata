//
//  DetailsCell.swift
//  Stationdata
//
//  Created by Beloizerov on 24.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

final class DetailsCell: UICollectionViewCell {
    
    private let chartView = UIView()
    private let chartMask = CAShapeLayer()
    private let lineLayer = CAShapeLayer()
    private let pointView = UIView()
    private let labelView = UILabel()
    private let valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        
        //chartView
        chartView.layer.mask = chartMask
        chartView.frame.origin = CGPoint(x: 0, y: 20)
        chartView.frame.size = CGSize(width: frame.width, height: frame.height - 53)
        contentView.addSubview(chartView)
        
        //line
        lineLayer.lineWidth = 3
        lineLayer.fillColor = UIColor.clear.cgColor
        chartView.layer.addSublayer(lineLayer)
        
        //point
        pointView.backgroundColor = .white
        pointView.frame.size = CGSize(width: 6, height: 6)
        pointView.layer.cornerRadius = 3
        pointView.layer.borderWidth = 2
        
        //label
        labelView.numberOfLines = 2
        labelView.textColor = #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1)
        labelView.font = .systemFont(ofSize: 11)
        contentView.addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        labelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        //bottomLine
        let line = CALayer()
        line.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        line.frame = CGRect(x: 0, y: frame.height - 33, width: frame.width, height: 0.5)
        contentView.layer.addSublayer(line)
        
        //value
        valueLabel.textColor = #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1)
        valueLabel.font = .systemFont(ofSize: 12)
        valueLabel.isHidden = true
        contentView.addSubview(valueLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        valueLabel.isHidden = true
    }
    
    func setResult(_ result: DetailsManager.Result?) {
        labelView.text = result?.label
        drawChar(result: result)
    }
    
    func setColor(_ color: Color?) {
        guard let color = color else { return }
        chartView.layer.contents = color.gradientImage?.cgImage
        pointView.layer.borderColor = color.color.cgColor
        lineLayer.strokeColor = color.color.cgColor
        valueLabel.textColor = color.color
    }
    
    // MARK: - Chart
    
    private func drawChar(result: DetailsManager.Result?) {
        guard let result = result, let middle = result.middle else { reset(); return }
        var size = chartView.frame.size
        size.height -= 8
        let linePath = UIBezierPath()
        let chartPath = CGMutablePath()
        let middleLinePoint = CGPoint(x: size.width / 2,
                                      y: size.height - CGFloat(middle) * size.height)
        if let start = result.start {
            let leftLinePoint = CGPoint(x: 0, y: size.height - CGFloat(start) * size.height)
            linePath.move(to: leftLinePoint)
            linePath.addLine(to: middleLinePoint)
            chartPath.move(to: CGPoint(x: 0, y: chartView.frame.height))
            chartPath.addLine(to: leftLinePoint)
        } else {
            linePath.move(to: middleLinePoint)
            chartPath.move(to: CGPoint(x: size.width / 2,
                                       y: chartView.frame.height))
        }
        chartPath.addLine(to: middleLinePoint)
        if let end = result.end {
            let rightLinePoint = CGPoint(x: size.width,
                                         y: size.height - CGFloat(end) * size.height)
            linePath.addLine(to: rightLinePoint)
            chartPath.addLine(to: rightLinePoint)
            chartPath.addLine(to: CGPoint(x: size.width,
                                          y: chartView.frame.height))
        } else {
            chartPath.addLine(to: CGPoint(x: size.width / 2,
                                          y: chartView.frame.height))
        }
        lineLayer.path = linePath.cgPath
        chartMask.path = chartPath
        pointView.center = CGPoint(x: middleLinePoint.x,
                                   y: middleLinePoint.y + chartView.frame.minY + lineLayer.lineWidth / 2)
        contentView.addSubview(pointView)
    }
    
    private func reset() {
        chartMask.path = nil
        lineLayer.path = nil
        pointView.removeFromSuperview()
    }
    
    // MARK: - Value
    
    func setValue(_ value: String?) {
        guard let value = value else { return }
        valueLabel.text = value
        valueLabel.frame.size = valueLabel.intrinsicContentSize
        valueLabel.center = CGPoint(x: pointView.center.x,
                                    y: pointView.frame.minY - valueLabel.frame.height)
        showValue(true)
    }
    
    func hideValue() {
        showValue(false)
    }
    
    private func showValue(_ show: Bool) {
        UIView.transition(with: self, duration: 0.4, options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self?.valueLabel.isHidden = !show
        }, completion: nil)
    }
    
}


