//
//  Location.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

final class Location: NSManagedObject {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
    
    @NSManaged private(set) var name: String
    @NSManaged private(set) var updateDate: Date?
    @NSManaged private var url_: String
    @NSManaged private var downloadState_: Int16
    @NSManaged private var ranges_: NSOrderedSet?
    
    var url: URL? {
        return URL(string: url_)
    }
    
    private var ranges: [LocationRanges] {
        get { return ranges_?.array as? [LocationRanges] ?? [] }
        set { ranges_ = NSOrderedSet(array: newValue) }
    }
    
    func ranges(for level: Int) -> LocationRanges? {
        let ranges = self.ranges
        guard level < ranges.count else { return nil }
        return ranges[level]
    }
    
    enum DownloadState: Int16 {
        case notDownloaded = 0, downloaded, haveUpdate
    }
    
    var downloadState: DownloadState {
        get { return DownloadState(rawValue: downloadState_) ?? .notDownloaded }
        set { downloadState_ = newValue.rawValue }
    }
    
    convenience init(name: String, url: URL, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        url_ = url.absoluteString
    }
    
    func setValues(_ array: [[Double?]]) {
        guard let context = managedObjectContext else { return }
        //self.values.forEach { value in context.delete(value) }
        let values = array.flatMap { value in LocationValue(values: value, in: context) }
        ranges = (0..<3).flatMap { createRange(for: $0, values: values) }
        updateDate = Date()
        downloadState = .downloaded
    }
    
    private func createRange(for level: Int, values: [LocationValue]) -> LocationRanges? {
        guard let context = managedObjectContext else { return nil }
        guard level != 0 else { return LocationRanges(values: values, in: context) }
        var resultValues = [LocationValue]()
        var tempValues = [LocationValue]()
        var compare: String?
        var year: Double?
        func addLocationValue() {
            let values: [Double?] = [
                year,
                nil,
                calcValue(from: tempValues, mean: true) { $0.maxTemp },
                calcValue(from: tempValues, mean: true) { $0.minTemp },
                calcValue(from: tempValues, mean: false) { $0.airFrost },
                calcValue(from: tempValues, mean: false) { $0.rainfall },
                calcValue(from: tempValues, mean: false) { $0.sunshine }
            ]
            tempValues = []
            compare = nil
            year = nil
            guard let newValue = LocationValue(values: values, in: context) else { return }
            resultValues.append(newValue)
        }
        for value in values {
            if compare == nil {
                tempValues.append(value)
                compare = value.label(for: level)
                year = value.year
            } else if compare == value.label(for: level) {
                tempValues.append(value)
            } else {
                addLocationValue()
            }
        }
        addLocationValue()
        return LocationRanges(values: resultValues, in: context)
    }
    
    private func calcValue(from values: [LocationValue], mean: Bool, _ transform: (LocationValue) -> Double?) -> Double? {
        var temp = (sum: 0.0, count: 0.0)
        for value in values {
            guard let double = transform(value) else { continue }
            temp.sum += double
            temp.count += 1
        }
        guard temp.count > 0 else { return nil }
        return mean ? temp.sum / temp.count : temp.sum
    }
    
}








