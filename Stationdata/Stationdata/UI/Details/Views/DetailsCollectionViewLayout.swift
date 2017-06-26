//
//  DetailsCollectionViewLayout.swift
//  Stationdata
//
//  Created by Beloizerov on 24.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit

final class DetailsCollectionViewLayout: UICollectionViewLayout {
    
    let itemSize = CGSize(width: 50, height: 153)
    let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
    let rangeSize = CGSize(width: 30, height: 153)
    
    func reset() {
        contentSize = CGSize()
        dataSourceDidUpdate = true
        cellAttrsDictionary = [:]
    }
    
    private var contentSize = CGSize()
    private var dataSourceDidUpdate = true
    private var cellAttrsDictionary = [IndexPath: UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView else { return }
        if !dataSourceDidUpdate {
            for section in 0..<collectionView.numberOfSections {
                if collectionView.numberOfItems(inSection: section) == 0 { continue }
                let indexPath = IndexPath(item: 0, section: section)
                if let attrs = cellAttrsDictionary[indexPath] {
                    var frame = attrs.frame
                    frame.origin.x = collectionView.contentOffset.x
                    attrs.frame = frame
                }
            }
        } else {
            var maxX: CGFloat = 0
            var y: CGFloat = 0
            for section in 0..<collectionView.numberOfSections {
                var maxY: CGFloat = 0
                var x: CGFloat = 0
                func configCell(indexPath: IndexPath, size: CGSize) {
                    let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    cellAttributes.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
                    maxY = max(maxY, size.height)
                    x += size.width
                    cellAttributes.zIndex = indexPath.item == 0 ? 2 : 1
                    cellAttrsDictionary[indexPath] = cellAttributes
                }
                if section % 2 == 1 {
                    for item in 0..<collectionView.numberOfItems(inSection: section) {
                        let indexPath = IndexPath(item: item, section: section)
                        let size = item == 0 ? rangeSize : itemSize
                        configCell(indexPath: indexPath, size: size)
                    }
                } else {
                    let indexPath = IndexPath(item: 0, section: section)
                    configCell(indexPath: indexPath, size: headerSize)
                }
                y += maxY
                maxX = max(maxX, x)
            }
            dataSourceDidUpdate = false
            contentSize = CGSize(width: maxX, height: y)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cellAttrsDictionary.values.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttrsDictionary[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
