//
//  LineScaleLayout.swift
//  ZMusicUIFrame
//
//  Created by lyxia on 2016/10/30.
//  Copyright © 2016年 lyxia. All rights reserved.
//

import UIKit

public class LineScaleLayout: UICollectionViewFlowLayout {
    override public init() {
        super.init()
        
        self.scrollDirection = .horizontal
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var collectionViewContentSize: CGSize {
        get {
            var contentSize = super.collectionViewContentSize
            let newWidth = contentSize.width + self.collectionView!.bounds.width - itemSize.width
            contentSize.width = newWidth
            return contentSize
        }
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        //proposedContentOffset是没有对齐到网格时本来应该停下的位置
        let horizontalCenter = proposedContentOffset.x + self.collectionView!.bounds.width / 2
        let targetRect = CGRect(origin: proposedContentOffset, size: self.collectionView!.bounds.size)
        let array = layoutAttributesForElements(in: targetRect)!
        
        let offsetAdjustment = array.reduce(CGFloat(Int.max), { (minOffset, layoutAttributes) -> CGFloat in
            let itemHorizontalCenter = layoutAttributes.center.x
            if CGFloat.abs(itemHorizontalCenter - horizontalCenter) < CGFloat.abs(minOffset) {
                return itemHorizontalCenter - horizontalCenter
            }
            return minOffset
        })
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    public var activeDistance: CGFloat = 10
    public var zoomFactor: CGFloat = 0.6
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array = super.layoutAttributesForElements(in: rect)
        let visibleRect = CGRect(origin: self.collectionView!.contentOffset, size: self.collectionView!.bounds.size)
        let offsetX = (self.collectionView!.bounds.width - itemSize.width) / 2
        array = array?.map({ (attributes) -> UICollectionViewLayoutAttributes in
            let newAttributes = attributes.copy() as! UICollectionViewLayoutAttributes
            var newFrame = newAttributes.frame
            newFrame.origin.x = newFrame.origin.x + offsetX
            newAttributes.frame = newFrame
            if newAttributes.frame.intersects(rect) {
                let distance = visibleRect.midX - newAttributes.center.x
                let normalizedDistance = distance / activeDistance
                if CGFloat.abs(distance) < activeDistance {
                    let zoom = 1 + zoomFactor * (1 - CGFloat.abs(normalizedDistance))
                    newAttributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
                    newAttributes.zIndex = 1
                }
            }
            return newAttributes
        })
        
        return array
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
