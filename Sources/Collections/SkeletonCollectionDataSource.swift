//
//  SkeletonCollectionDataSource.swift
//  SkeletonView-iOS
//
//  Created by Juanpe Catalán on 02/11/2017.
//  Copyright © 2017 SkeletonView. All rights reserved.
//

import UIKit

public typealias ReusableCellIdentifier = String

class SkeletonCollectionDataSource: NSObject {
    
    weak var originalTableViewDataSource: SkeletonTableViewDataSource?
    weak var originalCollectionViewDataSource: UICollectionViewDataSource?
    var rowHeight: CGFloat = 0.0
    
    convenience init(tableViewDataSource: SkeletonTableViewDataSource? = nil, collectionViewDataSource: UICollectionViewDataSource? = nil, rowHeight: CGFloat = 0.0) {
        self.init()
        self.originalTableViewDataSource = tableViewDataSource
        self.originalCollectionViewDataSource = collectionViewDataSource
        self.rowHeight = rowHeight
    }
}

// MARK: - UITableViewDataSource
extension SkeletonCollectionDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return originalTableViewDataSource?.numSections(in:tableView) ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return originalTableViewDataSource?.collectionSkeletonView(tableView, numberOfRowsInSection:section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = originalTableViewDataSource?.collectionSkeletonView(tableView, cellIdenfierForRowAt: indexPath) ?? ""
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDataSource
extension SkeletonCollectionDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let source = originalCollectionViewDataSource, source.responds(to: #selector(SkeletonCollectionViewDataSource.numSections(in:))) else {
            return 0
        }
        if let target = (originalCollectionViewDataSource as? NSObject)?.forwardingTarget(for: #selector(SkeletonCollectionViewDataSource.numSections(in:))) as? NSObject {
            return (target.perform(#selector(SkeletonCollectionViewDataSource.numSections(in:)), with: collectionView).takeRetainedValue() as? NSNumber)?.intValue ?? 0
        }
        return (originalCollectionViewDataSource?.perform(#selector(SkeletonCollectionViewDataSource.numSections(in:)), with: collectionView).takeRetainedValue() as? NSNumber)?.intValue ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let source = originalCollectionViewDataSource, source.responds(to: #selector(SkeletonCollectionViewDataSource.collectionSkeletonView(_:numberOfItemsInSection:))) else {
            return 0
        }
        return (originalCollectionViewDataSource?.perform(#selector(SkeletonCollectionViewDataSource.collectionSkeletonView(_:numberOfItemsInSection:)), with: collectionView, with: NSNumber(integerLiteral: section)).takeRetainedValue() as? NSNumber)?.intValue ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let block = { () -> String in
            guard let source = self.originalCollectionViewDataSource, source.responds(to: #selector(SkeletonCollectionViewDataSource.collectionSkeletonView(_:cellIdentifierForItemAt:))) else {
                return ""
            }
            return (self.originalCollectionViewDataSource?.perform(#selector(SkeletonCollectionViewDataSource.collectionSkeletonView(_:cellIdentifierForItemAt:)), with: collectionView, with: indexPath).takeRetainedValue() as? String) ?? ""
            }
        let cellIdentifier = block()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        return cell
    }
}
