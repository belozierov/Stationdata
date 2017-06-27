//
//  ListManager.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

protocol ListManagerDelegate: class {
    
    func dataDidReload()
    func listUpdated()
    
}

final class ListManager {
    
    weak var delegate: ListManagerDelegate?
    
    func updateLocationListFromServer() {
        guard let request = listRequest else { return }
        DownloadManager.download(request: request) { [unowned self] (data, _) in
            DispatchQueue.global(qos: .userInteractive).async {
                self.parseList(data: data)
            }
        }
    }
    
    private(set) var downloadingLocations = Set<Location>()
    
    func downloadLocation(at indexPath: IndexPath) {
        downloadLocation(fetchedResultsController.object(at: indexPath))
    }
    
    func downloadLocation(_ location: Location) {
        guard let url = location.url, !downloadingLocations.contains(location) else { return }
        downloadingLocations.insert(location)
        DownloadManager.download(request: URLRequest(url: url)) {
            [unowned self, weak location] (data, _) in
            DispatchQueue.global(qos: .userInteractive).async {
                guard let location = location else { return }
                self.downloadingLocations.remove(location)
                self.parseLocation(data: data, in: location)
            }
        }
    }
    
    // MARK: Locations parser
    
    private func parseList(data: Data?) {
        guard let data = data,
            let string = String(data: data, encoding: .utf8),
            let urls = findUrl(in: string)
            else {
                DispatchQueue.main.async { [unowned self] in self.delegate?.listUpdated() }
                return
        }
        var finded = filterHistoricalData(urls: urls)
        let exist = fetchedResultsController.fetchedObjects ?? []
        for location in exist {
            if location.downloadState == .downloaded, let request = checkUpdateRequest(for: location) {
                DownloadManager.download(request: request) { [unowned self] (_, response) in
                    DispatchQueue.global(qos: .userInteractive).async {
                        self.checkUpdate(for: location, response: response)
                    }
                }
            }
            guard let index = finded.index(where: { (name, _) in name == location.name })
                else { continue }
            finded.remove(at: index)
        }
        CoreDataStack.context.perform {
            for (name, url) in finded {
                _ = Location(name: name, url: url, in: CoreDataStack.context)
            }
            CoreDataStack.context.saveToPersistentStore(async: true)
            DispatchQueue.main.async { [unowned self] in self.delegate?.listUpdated() }
        }
    }
    
    private func findUrl(in string: String) -> [URL]? {
        let types = NSTextCheckingResult.CheckingType.link.rawValue
        guard let detect = try? NSDataDetector(types: types) else { return nil }
        let range = NSRange(location: 0, length: string.characters.count)
        let matches = detect.matches(in: string, options: .reportCompletion, range: range)
        return Array(Set(matches.flatMap { match in match.url }))
    }
    
    private func filterHistoricalData(urls: [URL]) -> [(name: String, url: URL)] {
        let filterUrl = "http://www.metoffice.gov.uk/pub/data/weather/uk/climate/stationdata/"
        return urls.filter { url in
            url.absoluteString.hasPrefix(filterUrl) && url.absoluteString.hasSuffix("data.txt")
        }.map { url in
            (String(url.lastPathComponent.characters.dropLast(8)).capitalized, url)
        }
    }
    
    private var listRequest: URLRequest? {
        let urlString = "https://data.gov.uk/dataset/historic-monthly-meteorological-station-data"
        guard let url = URL(string: urlString) else { return nil }
        return URLRequest(url: url)
    }
    
    // MARK: Location update check
    
    private func checkUpdate(for location: Location, response: URLResponse?) {
        guard let updateDate = location.updateDate,
            let date = getDate(from: response as? HTTPURLResponse), updateDate < date
            else { return }
        CoreDataStack.context.perform {
            location.downloadState = .haveUpdate
            CoreDataStack.context.saveToPersistentStore(async: true)
        }
    }
    
    private func getDate(from response: HTTPURLResponse?) -> Date? {
        guard let modified = response?.allHeaderFields["Last-Modified"] as? String,
            modified.characters.count >= 24,
            let day = Int(modified[5..<7]),
            let month = shortMonthSymbols.index(where: { $0 == modified[8..<11] }),
            let year = Int(modified[12..<16]),
            let hour = Int(modified[17..<19]),
            let min = Int(modified[20..<22]),
            let sec = Int(modified[23..<25])
            else { return nil }
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.day = day
        components.hour = hour
        components.minute = min
        components.second = sec
        return Calendar.current.date(from: components)
    }
    
    private lazy var shortMonthSymbols: [String] = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        return calendar.shortMonthSymbols
    }()
    
    private func checkUpdateRequest(for location: Location) -> URLRequest? {
        guard let url = location.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        return request
    }
    
    // MARK: LocationValues parser
    
    private func parseLocation(data: Data?, in location: Location) {
        guard let data = data, !data.isEmpty else { return }
        let characters = CharacterSet(charactersIn: " #")
        func parseValues(from string: String) -> [Float?] {
            return string.components(separatedBy: characters)
                .filter { string in !string.isEmpty && string != "Provisional" }
                .map(Float.init)
        }
        let separator = "degC    degC    days      mm   hours"
        guard let values = String(data: data, encoding: .utf8)?
            .components(separatedBy: separator).last?
            .components(separatedBy: CharacterSet.newlines)
            .map(parseValues)
            else { return }
        CoreDataStack.context.perform {
            location.setValues(values)
            CoreDataStack.context.saveToPersistentStore(async: true)
        }
    }
    
    // MARK: NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: "ListManager")
        do { try fetchedResultsController.performFetch() } catch {}
        if fetchedResultsController.fetchedObjects?.isEmpty != false {
            self.updateLocationListFromServer()
        }
        return fetchedResultsController
    }()
    
    func refetchResults(name: String?) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
        if let name = name, !name.isEmpty {
            fetchedResultsController.fetchRequest.predicate
                = NSPredicate(format: "name BEGINSWITH[cd] %@", name)
        } else {
            fetchedResultsController.fetchRequest.predicate = nil
        }
        do { try fetchedResultsController.performFetch() } catch {}
        delegate?.dataDidReload()
    }
    
}
