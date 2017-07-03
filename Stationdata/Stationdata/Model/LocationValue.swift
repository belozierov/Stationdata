//
//  LocationValue.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

final class LocationValue: NSManagedObject {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<LocationValue> {
        return NSFetchRequest<LocationValue>(entityName: "LocationValue")
    }
    
    @NSManaged private var year_: Int16
    @NSManaged private var month: Int16
    @NSManaged private var tmax: NSNumber?
    @NSManaged private var tmin: NSNumber?
    @NSManaged private var af: NSNumber?
    @NSManaged private var rain: NSNumber?
    @NSManaged private var sun: NSNumber?
    
    var year: Float? { return Float(year_) }
    var maxTemp: Float? { return tmax?.floatValue }
    var minTemp: Float? { return tmin?.floatValue }
    var airFrost: Float? { return af?.floatValue }
    var rainfall: Float? { return rain?.floatValue }
    var sunshine: Float? { return sun?.floatValue }
    
    @NSManaged private var label_: String?
    
    func label(for level: Int) -> String? {
        if let label = label_ { return label }
        switch level {
        case 0: label_ = Calendar.current.shortMonthSymbols[Int(month - 1)] + "\n\(year_)"
        case 1: label_ = year_.description + "\n"
        case 2: label_ = "\((year_ / 10))0-\n\(year_ / 10 + 1)0"
        default: break
        }
        return label_
    }
    
    convenience init?(values: [Float?], in context: NSManagedObjectContext) {
        guard values.count == 7 else { return nil }
        self.init(context: context)
        self.year_ = Int16(values[0] ?? 0)
        self.month = Int16(values[1] ?? 0)
        tmax = number(from: values[2])
        tmin = number(from: values[3])
        af = number(from: values[4])
        rain = number(from: values[5])
        sun = number(from: values[6])
    }
    
    private func number(from float: Float?) -> NSNumber? {
        guard let float = float else { return nil }
        return NSNumber(value: float)
    }
    
}
