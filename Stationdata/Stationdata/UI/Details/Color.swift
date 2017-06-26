//
//  Color.swift
//  Stationdata
//
//  Created by Beloizerov on 24.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

enum Color {
    
    case maxTemp, minTemp, airFrost, rainfall, sunshine
    
    var color: UIColor {
        switch self {
        case .maxTemp: return #colorLiteral(red: 0.8509803922, green: 0.1254901961, blue: 0.2352941176, alpha: 1)
        case .minTemp: return #colorLiteral(red: 0.3647058824, green: 0.7607843137, blue: 0.9882352941, alpha: 1)
        case .airFrost: return #colorLiteral(red: 0.07450980392, green: 0.4705882353, blue: 0.8039215686, alpha: 1)
        case .rainfall: return #colorLiteral(red: 0.2274509804, green: 0.3882352941, blue: 0.5294117647, alpha: 1)
        case .sunshine: return #colorLiteral(red: 0.9803921569, green: 0.6392156863, blue: 0.1568627451, alpha: 1)
        }
    }
    
    // MARK: - Gradient
    
    private static var gradien = [Color: UIImage]()
    
    var gradientImage: UIImage? {
        if let image = Color.gradien[self] { return image }
        let image = makeGradient()
        Color.gradien[self] = image
        return image
    }
    
    private func makeGradient() -> UIImage? {
        let color = self.color
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame.size = CGSize(width: 50, height: 84)
        let gradient = CAGradientLayer()
        gradient.frame = layer.bounds
        gradient.colors = [color.withAlphaComponent(0.25).cgColor,
                           color.withAlphaComponent(0.05).cgColor]
        layer.insertSublayer(gradient, at: 0)
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext()
            else { UIGraphicsEndImageContext(); return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
