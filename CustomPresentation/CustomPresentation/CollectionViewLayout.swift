/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class CollectionViewLayout: UICollectionViewFlowLayout {
  
  var insertIndexPaths = NSMutableArray()
  var deleteIndexPaths = NSMutableArray()
  var center = CGPointZero
  
  init(traitCollection: UITraitCollection) {
    super.init()
    
    scrollDirection = .Vertical
    minimumInteritemSpacing = 10.0;
    minimumLineSpacing = 10.0;
    headerReferenceSize = CGSizeZero;
    footerReferenceSize = CGSizeZero;
    
    if traitCollection.userInterfaceIdiom == .Pad {
      itemSize = CGSize(width: 359.0, height: 208.0)
      sectionInset = UIEdgeInsets(top: 40.0, left: 20.0,
        bottom: 40.0, right: 20.0)
    } else {
      itemSize = CGSize(width: 145.0, height: 84.0)
      sectionInset = UIEdgeInsets(top: 20.0, left: 10.0,
        bottom: 20.0, right: 10.0)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  override func prepareForCollectionViewUpdates(
    updateItems: [UICollectionViewUpdateItem]) {
      
      super.prepareForCollectionViewUpdates(updateItems)
      
      deleteIndexPaths.removeAllObjects()
      insertIndexPaths.removeAllObjects()
      
      for update in updateItems {
        if update.updateAction == UICollectionUpdateAction.Delete {
          deleteIndexPaths.addObject(update.indexPathBeforeUpdate!)
        } else if update.updateAction == UICollectionUpdateAction.Insert {
          insertIndexPaths.addObject(update.indexPathAfterUpdate!)
        }
      }
  }
  
  override func finalizeCollectionViewUpdates() {
    super.finalizeCollectionViewUpdates()
    
    deleteIndexPaths.removeAllObjects()
    insertIndexPaths.removeAllObjects()
  }
  
  override func initialLayoutAttributesForAppearingItemAtIndexPath(
    itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
      
      var attributes: UICollectionViewLayoutAttributes? =
      super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
      
      if insertIndexPaths.containsObject(itemIndexPath) {
        if attributes == nil {
          attributes = layoutAttributesForItemAtIndexPath(itemIndexPath)
        }
        
        let cellWidth = itemSize.width
        let centerX = (UInt8(itemIndexPath.row) % 2) == 0 ?
          -cellWidth : collectionView!.bounds.size.width + cellWidth
        
        var center = attributes!.center
        center.x = centerX
        
        attributes!.center = center
      }
      
      return attributes
  }
  
  override func finalLayoutAttributesForDisappearingItemAtIndexPath(
    itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
      
      var attributes: UICollectionViewLayoutAttributes? =
      super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)
      
      if deleteIndexPaths.containsObject(itemIndexPath) {
        if attributes == nil {
          attributes = layoutAttributesForItemAtIndexPath(itemIndexPath)
        }
        
        let cellWidth = itemSize.width
        let centerX = (UInt8(itemIndexPath.row) % 2) == 0 ?
          -cellWidth : collectionView!.bounds.size.width + cellWidth
        
        var center = attributes!.center
        center.x = centerX
        
        attributes!.center = center
      }
      
      return attributes
  }
}
