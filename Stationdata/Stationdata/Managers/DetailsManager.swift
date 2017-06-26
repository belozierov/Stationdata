//
//  DetailsManager.swift
//  Stationdata
//
//  Created by Beloizerov on 24.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation
import CoreGraphics

final class DetailsManager {
    
    weak var location: Location? {
        didSet {
            go(to: 2)
        }
    }
    
    private(set) var values = [LocationValue]()
    private var ranges = [Range<Double>?]()
    
    // MARK: Levels
    
    private(set) var currentLevel = 0
    
    func levelUp() {
        go(to: currentLevel + 1)
    }
    
    func levelDown() {
        go(to: currentLevel - 1)
    }
    
    private func go(to level: Int) {
        currentLevel = level
        let currentRange = location?.ranges(for: level)
        values = currentRange?.values ?? []
        ranges = [
            currentRange?.maxTemp,
            currentRange?.minTemp,
            currentRange?.airFrost,
            currentRange?.rainfall,
            currentRange?.sunshine
        ]
    }
    
    // MARK: Result
    
    struct Result {
        
        let start: CGFloat?
        let middle: CGFloat?
        let end: CGFloat?
        let label: String?
        
        typealias Values = (start: Double?, middle: Double?, end: Double?)
        
        fileprivate init?(_ values: Values, range: Range<Double>?, label: String?) {
            guard let middle = values.middle, let range = range else { return nil }
            let differ = range.upperBound - range.lowerBound
            func calc(from: Double?, to: Double?, range: Range<Double>) -> CGFloat? {
                guard let from = from, let to = to else { return nil }
                let center = (from + to) / 2
                return CGFloat((center - range.lowerBound) / differ)
            }
            start = calc(from: values.start, to: values.middle, range: range)
            end = calc(from: values.middle, to: values.end, range: range)
            self.middle = CGFloat((middle - range.lowerBound) / differ)
            self.label = label
        }
        
    }
    
    subscript(_ indexPath: IndexPath) -> Result? {
        let indexPath = convertIndexPathForSubscript(indexPath)
        let value = values[indexPath.item]
        let array: [LocationValue?] = [
            indexPath.item > 0 ? values[indexPath.item - 1] : nil,
            value,
            indexPath.item + 1 < values.count ? values[indexPath.item + 1] : nil]
        let range = ranges[indexPath.section]
        switch indexPath.section {
        case 0:
            let values = resultValues(from: array, transform: { $0?.maxTemp })
            return Result(values, range: range, label: value.label(for: currentLevel))
        case 1:
            let values = resultValues(from: array, transform: { $0?.minTemp })
            return Result(values, range: range, label: value.label(for: currentLevel))
        case 2:
            let values = resultValues(from: array, transform: { $0?.airFrost })
            return Result(values, range: range, label: value.label(for: currentLevel))
        case 3:
            let values = resultValues(from: array, transform: { $0?.rainfall })
            return Result(values, range: range, label: value.label(for: currentLevel))
        case 4:
            let values = resultValues(from: array, transform: { $0?.sunshine })
            return Result(values, range: range, label: value.label(for: currentLevel))
        default: return nil
        }
    }
    
    subscript(result indexPath: IndexPath) -> String? {
        let indexPath = convertIndexPathForSubscript(indexPath)
        let value = values[indexPath.item]
        switch indexPath.section {
        case 0: return label(for: value.maxTemp)
        case 1: return label(for: value.minTemp)
        case 2 where value.airFrost != nil: return Int(value.airFrost!).description
        case 3: return label(for: value.rainfall)
        case 4: return label(for: value.sunshine)
        default: return nil
        }
    }
    
    typealias Ranges = (lower: String?, middle: String?, upper: String?)
    
    subscript(ranges indexPath: IndexPath) -> Ranges {
        let section = convertIndexPathForSubscript(indexPath).section
        guard let range = ranges[section] else { return (nil, nil, nil) }
        switch section {
        case 2: return (Int(range.lowerBound).description,
                        Int(mean(range: range)).description,
                        Int(range.upperBound).description)
        default: return (label(for: range.lowerBound),
                         label(for: mean(range: range)),
                         label(for: range.upperBound))
        }
    }
    
    private func label(for double: Double?) -> String? {
        guard let double = double else { return nil }
        return String(format: "%.01f", double)
    }
    
    private func mean(range: Range<Double>) -> Double {
        return (range.lowerBound + range.upperBound) / 2
    }
    
    private func convertIndexPathForSubscript(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(item: indexPath.item - 1, section: indexPath.section / 2)
    }
    
    private func resultValues(from values: [LocationValue?], transform: (LocationValue?) -> Double?) -> Result.Values {
        return (transform(values[0]), transform(values[1]), transform(values[2]))
    }
    
}
