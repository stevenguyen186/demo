//
//  CustomLayout.swift
//  VPBank
//
//  Created by Van Nguyen on 8/15/20.
//  Copyright © 2020 Van Nguyen. All rights reserved.
//

import UIKit

let CELL_HEIGHT_BASE: Double = 60.0
let CELL_WIDTH_BASE: Double = 100.0

protocol CustomLayoutDelegate: class {
    func sizeForItemAtIndexPath(indexPath: IndexPath) -> CGSize
}

extension CustomLayoutDelegate {
    func sizeForItemAtIndexPath(indexPath: IndexPath) -> CGSize {
        return CGSize.zero
    }
}

class CustomLayout: UICollectionViewLayout {
    var cellAttrsDictionary = Dictionary<IndexPath, UICollectionViewLayoutAttributes>()
    
    var contentSize = CGSize.zero
    
    var dataSourceDidUpdate = true
    
    weak var delegate: CustomLayoutDelegate?

    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func prepare() {
        
        // Only update header cells.
        if !dataSourceDidUpdate {
            
            // Determine current content offsets.
            let xOffset = collectionView!.contentOffset.x
            let yOffset = collectionView!.contentOffset.y
            
            if collectionView!.numberOfSections > 0 {
                for section in 0...collectionView!.numberOfSections-1 {
                    
                    // Confirm the section has items.
                    if (collectionView?.numberOfItems(inSection: section))! > 0 {
                        
                        // Update all items in the first column.
                        if section == 0 {
                            for item in 0...collectionView!.numberOfItems(inSection: section)-1 {
                                
                                // Build indexPath to get attributes from dictionary.
                                let indexPath = IndexPath(item: item, section: section)
                                
                                // Update x-position to follow user.
                                if let attrs = cellAttrsDictionary[indexPath] {
                                    
                                    var frame = attrs.frame

                                    // Also update y-position for corner cell.
                                    if item == 0 {
                                        frame.origin.y = yOffset
                                    }
                                    frame.origin.x = xOffset
                                    attrs.frame = frame
                                }
                                
                            }
                            
                            // For all other sections, we only need to update
                            // the x-position for the first item.
                        } else {
                            
                            // Build indexPath to get attributes from dictionary.
                            let indexPath = IndexPath(item: 0, section: section)
                            
                            // Update y-position to follow user.
                            if let attrs = cellAttrsDictionary[indexPath] {
                                var frame = attrs.frame
                                frame.origin.y = yOffset
                                attrs.frame = frame

                            }
                            
                        }
                    }
                }
            }
            
            // Do not run attribute generation code
            // unless data source has been updated.
            return
        }
        
        // Acknowledge data source change, and disable for next time.
        dataSourceDidUpdate = false

        // Cycle through each section of the data source.
        if (collectionView?.numberOfSections)! > 0 {
            for section in 0...collectionView!.numberOfSections-1 {
                var sectionHeight: Double = 0
                // Cycle through each item in the section.
                if (collectionView?.numberOfItems(inSection: section))! > 0 {
                    for item in 0...collectionView!.numberOfItems(inSection: section)-1 {
                        // Build the UICollectionVieLayoutAttributes for the cell.
                        let cellIndex = IndexPath(item: item, section: section)
                        let xPos = Double(section) * CELL_WIDTH_BASE
                        let yPos = sectionHeight
                        
                        var cellHeight: Double = CELL_HEIGHT_BASE
                        var cellWidth: Double = CELL_WIDTH_BASE
                        if let delegate = delegate {
                            let size = delegate.sizeForItemAtIndexPath(indexPath: cellIndex)
                            cellHeight = Double(size.height)
                            cellWidth = Double(size.width)
                        }
                        
                        let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndex as IndexPath)
                        cellAttributes.frame = CGRect(x: xPos, y: yPos, width: cellWidth, height: cellHeight)
                        
                        // Determine zIndex based on cell type.
                        if section == 0 && item == 0 {
                            cellAttributes.zIndex = 4
                        } else if section == 0 {
                            cellAttributes.zIndex = 3
                        } else if item == 0 {
                            cellAttributes.zIndex = 2
                        } else {
                            cellAttributes.zIndex = 1
                        }
                        
                        // Save the attributes.
                        cellAttrsDictionary[cellIndex] = cellAttributes
                        sectionHeight+=cellHeight
                    }
                }
                
            }
        }
        
        // Update content size.
        let contentWidth = Double(collectionView!.numberOfSections) * CELL_WIDTH_BASE
        let contentHeight = Double(collectionView!.numberOfItems(inSection: 0)) * CELL_HEIGHT_BASE
        self.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Create an array to hold all elements found in our current view.
        var attributesInRect = [UICollectionViewLayoutAttributes]()
        
        // Check each element to see if it should be returned.

        for cellAttributes in cellAttrsDictionary.values {
            if rect.intersects(cellAttributes.frame) {
                attributesInRect.append(cellAttributes)
            }
        }
        
        // Return list of elements.
        return attributesInRect
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attrsDict = cellAttrsDictionary[indexPath] {
            return attrsDict
        }
        return nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
