//
//  DetailsViewController.swift
//  Stationdata
//
//  Created by Beloizerov on 24.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

final class DetailsViewController: UICollectionViewController {
    
    convenience init() {
        self.init(collectionViewLayout: DetailsCollectionViewLayout())
        installsStandardGestureForInteractiveMovement = false
        
        //CollectionView
        collectionView?.backgroundColor = .white
        collectionView?.register(DetailsCell.self, forCellWithReuseIdentifier: "DetailsCell1")
        collectionView?.register(DetailsCell.self, forCellWithReuseIdentifier: "DetailsCell3")
        collectionView?.register(DetailsCell.self, forCellWithReuseIdentifier: "DetailsCell5")
        collectionView?.register(DetailsCell.self, forCellWithReuseIdentifier: "DetailsCell7")
        collectionView?.register(DetailsCell.self, forCellWithReuseIdentifier: "DetailsCell9")
        collectionView?.register(DetailsHeaderCell.self, forCellWithReuseIdentifier: "HeaderCell")
        collectionView?.register(DetailsRangeCell.self, forCellWithReuseIdentifier: "RangeCell")
        collectionView?.isPrefetchingEnabled = false
        
        //GestureRecognizerі
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognizerActivate(_:)))
        collectionView?.addGestureRecognizer(pinchRecognizer)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognizerActivate(_:)))
        collectionView?.addGestureRecognizer(tapRecognizer)
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapRecognizerActivate(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        tapRecognizer.require(toFail: doubleTapRecognizer)
        collectionView?.addGestureRecognizer(doubleTapRecognizer)
        let twoDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(twoDoubleTapRecognizerActivate(_:)))
        twoDoubleTapRecognizer.numberOfTapsRequired = 2
        twoDoubleTapRecognizer.numberOfTouchesRequired = 2
        collectionView?.addGestureRecognizer(twoDoubleTapRecognizer)
    }
    
    // MARK: - DetailsManager
    
    private let manager = DetailsManager()
    
    var location: Location? {
        get {
            return manager.location
        }
        set {
            guard location != newValue else { return }
            manager.location = newValue
            title = newValue?.name
            reloadData()
        }
    }
    
    // MARK: - UICollectionViewDelegate and DataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 11
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section % 2 == 1 ? manager.values.count + 1 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch (indexPath.section, indexPath.item) {
        case (let section, _) where section % 2 == 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! DetailsHeaderCell
        case (_, 0):
            return collectionView.dequeueReusableCell(withReuseIdentifier: "RangeCell", for: indexPath) as! DetailsRangeCell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailsCell\(indexPath.section)", for: indexPath) as! DetailsCell
            setColor(for: cell, at: indexPath.section)
            return cell
        }
    }
    
    private func setColor(for cell: DetailsCell, at section: Int) {
        switch section {
        case 1: cell.setColor(.maxTemp)
        case 3: cell.setColor(.minTemp)
        case 5: cell.setColor(.airFrost)
        case 7: cell.setColor(.rainfall)
        case 9: cell.setColor(.sunshine)
        default: break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.item) {
        case (let section, _) where section % 2 == 0:
            guard let cell = cell as? DetailsHeaderCell else { break }
            cell.label = sectionTitle(section: indexPath.section)
        case (_, 0):
            guard let cell = cell as? DetailsRangeCell else { break }
            cell.setRange(manager[ranges: indexPath])
        default:
            guard let cell = cell as? DetailsCell else { break }
            cell.setResult(manager[indexPath])
        }
    }
    
    private func sectionTitle(section: Int) -> String? {
        switch section / 2 {
        case 0: return "Mean maximum temperature (degC)".localized
        case 1: return "Mean minimum temperature (degC)".localized
        case 2: return "Days of air frost (days)".localized
        case 3: return "Total rainfall (mm)".localized
        case 4: return "Total sunshine duration (hours)".localized
        default: return nil
        }
    }
    
    // MARK: - UIPinchGestureRecognizer
    
    private var selectedCell: IndexPath?
    private var lastScale: CGFloat = 1
    
    func pinchRecognizerActivate(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            if lastScale * 2 < recognizer.scale, manager.currentLevel > 0 {
                lastScale = recognizer.scale
                level(up: false, recognizer: recognizer)
            } else if lastScale / 2 > recognizer.scale, manager.currentLevel < 2  {
                lastScale = recognizer.scale
                level(up: true, recognizer: recognizer)
            }
        case .ended: lastScale = 1
        default: break
        }
    }
    
    func tapRecognizerActivate(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended,
            let indexPath = collectionView?.indexPathForItem(at: recognizer.location(in: collectionView))
            else { return }
        if let indexPath = selectedCell {
            (collectionView?.cellForItem(at: indexPath) as? DetailsCell)?.hideValue()
        }
        if selectedCell != indexPath,
            let cell = collectionView?.cellForItem(at: indexPath) as? DetailsCell {
            cell.setValue(manager[result: indexPath])
            selectedCell = indexPath
        } else {
            selectedCell = nil
        }
        
    }
    
    func doubleTapRecognizerActivate(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended, manager.currentLevel > 0  else { return }
        level(up: false, recognizer: recognizer)
    }
    
    func twoDoubleTapRecognizerActivate(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended, manager.currentLevel < 2  else { return }
        level(up: true, recognizer: recognizer)
    }
    
    private func level(up: Bool, recognizer: UIGestureRecognizer) {
        let year = self.year(at: recognizer.location(in: collectionView).x)
        up ? manager.levelUp() : manager.levelDown()
        reloadData(scrollTo: year)
    }
    
    private func year(at x: CGFloat) -> Float? {
        if let item = collectionView?.indexPathForItem(at: CGPoint(x: x, y: 80))?.item,
            item > 1, item - 1 < manager.values.count {
            return manager.values[item - 1].year
        }
        return nil
    }
    
    private func reloadData(scrollTo year: Float? = nil) {
        guard let collectionView = collectionView else { return }
        selectedCell = nil
        (collectionViewLayout as? DetailsCollectionViewLayout)?.reset()
        collectionView.reloadData()
        guard let year = year else { return }
        collectionView.layoutIfNeeded()
        if let index = manager.values.index(where: { $0.year ?? 0 >= year }) {
            let x = CGFloat(abs(index.distance(to: manager.values.startIndex)) * 50 + 5)
            let maxX = collectionView.contentSize.width - UIScreen.main.bounds.width
            collectionView.contentOffset = CGPoint(x: min(x, maxX), y: collectionView.contentOffset.y)
        } else if manager.values.first?.year ?? 0 < year {
            let maxX = collectionView.contentSize.width - UIScreen.main.bounds.width
            collectionView.contentOffset = CGPoint(x: maxX, y: collectionView.contentOffset.y)
        } else {
            collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentOffset.y)
        }
    }
    
}
