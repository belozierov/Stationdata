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
    
    var year: Double? { return Double(year_) }
    var maxTemp: Double? { return tmax?.doubleValue }
    var minTemp: Double? { return tmin?.doubleValue }
    var airFrost: Double? { return af?.doubleValue }
    var rainfall: Double? { return rain?.doubleValue }
    var sunshine: Double? { return sun?.doubleValue }
    
    func label(for level: Int) -> String? {
        switch level {
        case 0: return Calendar.current.shortMonthSymbols[Int(month - 1)] + "\n\(year_)"
        case 1: return year_.description + "\n"
        case 2: return "\((year_ / 10))0-\n\(year_ / 10 + 1)0"
        default: return nil
        }
    }
    
    convenience init?(values: [Double?], in context: NSManagedObjectContext) {
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
    
    private func number(from double: Double?) -> NSNumber? {
        guard let double = double else { return nil }
        return NSNumber(value: double)
    }
    
}
