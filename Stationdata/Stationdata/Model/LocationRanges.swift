//
//  LocationRanges.swift
//  Stationdata
//
//  Created by Beloizerov on 24.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

final class LocationRanges: NSManagedObject {
    
    @NSManaged private var lowerTmax: NSNumber?
    @NSManaged private var upperTmax: NSNumber?
    @NSManaged private var lowerTmin: NSNumber?
    @NSManaged private var upperTmin: NSNumber?
    @NSManaged private var lowerAf: NSNumber?
    @NSManaged private var upperAf: NSNumber?
    @NSManaged private var lowerRain: NSNumber?
    @NSManaged private var upperRain: NSNumber?
    @NSManaged private var lowerSun: NSNumber?
    @NSManaged private var upperSun: NSNumber?
    @NSManaged private var values_: NSOrderedSet?

    private(set) var maxTemp: Range<Double>? {
        get { return range(lower: lowerTmax, upper: upperTmax) }
        set { setRange(newValue, lower: &lowerTmax, upper: &upperTmax) }
    }
    
    private(set) var minTemp: Range<Double>? {
        get { return range(lower: lowerTmin, upper: upperTmin) }
        set { setRange(newValue, lower: &lowerTmin, upper: &upperTmin) }
    }
    
    private(set) var airFrost: Range<Double>? {
        get { return range(lower: lowerAf, upper: upperAf) }
        set { setRange(newValue, lower: &lowerAf, upper: &upperAf) }
    }
    
    private(set) var rainfall: Range<Double>? {
        get { return range(lower: lowerRain, upper: upperRain) }
        set { setRange(newValue, lower: &lowerRain, upper: &upperRain) }
    }
    
    private(set) var sunshine: Range<Double>? {
        get { return range(lower: lowerSun, upper: upperSun) }
        set { setRange(newValue, lower: &lowerSun, upper: &upperSun) }
    }
    
    private(set) var values: [LocationValue] {
        get { return values_?.array as? [LocationValue] ?? [] }
        set { values_ = NSOrderedSet(array: newValue) }
    }
    
    convenience init(values: [LocationValue], in context: NSManagedObjectContext) {
        self.init(context: context)
        maxTemp = range(values: values) { $0.maxTemp }
        minTemp = range(values: values) { $0.minTemp }
        airFrost = range(values: values) { $0.airFrost }
        rainfall = range(values: values) { $0.rainfall }
        sunshine = range(values: values) { $0.sunshine }
        self.values = values
    }
    
    private func range<T: Comparable>(values: [LocationValue], transform: (LocationValue) -> T?) -> Range<T>? {
        var temp: (lower: T?, upper: T?) = (nil, nil)
        for value in values {
            guard let t = transform(value) else { continue }
            if let l = temp.lower { temp.lower = min(l, t) } else { temp.lower = t }
            if let u = temp.upper { temp.upper = max(u, t) } else { temp.upper = t }
        }
        guard let lower = temp.lower, let upper = temp.upper else { return nil }
        return Range(uncheckedBounds: (lower: lower, upper: upper))
    }
    
    private func range(lower: NSNumber?, upper: NSNumber?) -> Range<Double>? {
        guard let lower = lower, let upper = upper else { return nil }
        return Range(uncheckedBounds: (lower: lower.doubleValue, upper: upper.doubleValue))
    }
    
    private func setRange(_ range: Range<Double>?, lower: inout NSNumber?, upper: inout NSNumber?) {
        lower = number(from: range?.lowerBound)
        upper = number(from: range?.upperBound)
    }
    
    private func number(from double: Double?) -> NSNumber? {
        guard let double = double else { return nil }
        return NSNumber(value: double)
    }
    
}
