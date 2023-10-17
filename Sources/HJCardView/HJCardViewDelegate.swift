import Foundation

public protocol HJCardViewDelegate: AnyObject {
    
    //func cardView(_ cardView: HJCardView, didSelectedItemAtIndex: Int)\
    
    /// this method is called when the center item is called
    func centerItemDidSelected(in cardView: HJCardView)
    
    /// the size of the item closest to the center item
    func itemSize(in cardView: HJCardView) -> CGSize
    
    /**
     * the size of the center item
     *
     * when the method 'centerItemSize(of:)' isn't implemented, the size of the center item is equal to the item size
     */
//    func centerItemSize(in cardView: HJCardView) -> CGSize
    
    
// setting for edge items
    
    /**
     * Because items can be placed horizontally and vertically, there is no need to define top, bottom, left or right. Instead, the head represents the left/top, and the tail represents the right/bottom.
     *
     * If there is no implementation of these two methods, the 'numberOfItemsInBothDirection(in:)' will be returned by default
     */
    func numberOfItemsInHeadDirection(in cardView: HJCardView) -> Int
    func numberOfItemsInTailDirection(in cardView: HJCardView) -> Int
    
    /**
     * how many items can be displayed in one direction
     *
     * for example if the number is 3, the views will shows like
     * |item 1| |item2| |item3| |item2| |item1|, the items 3 would be the center item
     *
     * the default value is 5
     */
    func numberOfItemsInBothDirection(in cardView: HJCardView) -> Int
    
    /**
     * the rotation angle of the item located at the edge,
     * the center item's rotation angle is zero,
     * the remaining items are proportional to their distance to from the center item
     *
     * the default value is .pi/9.
     */
    func angleRotationOfEdgeItem(in CardView: HJCardView) -> CGFloat
    
    /**
     * the scaling ratio of the edge items to the center item
     * the remaining items are proportional to their distance to from the center item
     *
     * the default value is 0.8
     */
    func scalingRatioOfEdgeItem(in cardView: HJCardView) -> CGFloat
    
    /**
     * the ratio that ( edge item distance to center / half width of  the card view)
     * the remaining items are proportional to their distance to from the center item
     * zero means the center item overlap the edge items
     *
     * the default value is 0.8
     */
    func distanceRatioToCenterOfEdgeItem(in cardView: HJCardView) -> CGFloat
    
    
// setting for center item
    
    /**
     * the angle to rotate when the center item is dragged to the edge
     *
     * the default value is .pi/6
     */
    func angleRotationOfCenterItem(in cardView: HJCardView) -> CGFloat
    
    /**
     * the scaling ratio when the center item is dragged to the edge
     *
     * the default value is 0.8
     */
    func scalingRatioOfCenterItem(in cardView: HJCardView) -> CGFloat
    
    /**
     * the ratio that (center item max distance to center while dragging / half width of the card view)
     *
     * the default value is 1.0
     */
    func distanceRatioToCenterOfCenterItem(in cardView: HJCardView) -> CGFloat
}

let DefaultNumberOfItemsInBothDirection: Int          = 5
let DefaultAngleRotationOfEdgeItem: CGFloat           = .pi/9
let DefaultScalingRatioOfEdgeItem: CGFloat            = 0.8
let DefaultDistanceRatioToCenterOfEdgeItem: CGFloat   = 0.8
let DefaultAngleRotationOfCenterItem: CGFloat         = .pi/6
let DefaultScalingRatioOfCenterItem: CGFloat          = 0.8
let DefaultDistanceRatioToCenterOfCenterItem: CGFloat = 1.0


extension HJCardViewDelegate {
    
    public func itemSize(in cardView: HJCardView) -> CGSize {
        return CGSize.zero
    }
    
//    public func centerItemSize(in cardView: HJCardView) -> CGSize {
//        return itemSize(in: cardView)
//    }
    
    public func numberOfItemsInHeadDirection(in cardView: HJCardView) -> Int {
        return numberOfItemsInBothDirection(in: cardView)
    }
    
    public func numberOfItemsInTailDirection(in cardView: HJCardView) -> Int {
        return numberOfItemsInBothDirection(in: cardView)
    }
    
    public func numberOfItemsInBothDirection(in cardView: HJCardView) -> Int {
        return DefaultNumberOfItemsInBothDirection
    }
    
    public func angleRotationOfEdgeItem(in cardView: HJCardView) -> CGFloat {
        return DefaultAngleRotationOfEdgeItem
    }
    
    public func scalingRatioOfEdgeItem(in cardView: HJCardView) -> CGFloat {
        return DefaultScalingRatioOfEdgeItem
    }
    
    public func distanceRatioToCenterOfEdgeItem(in cardView: HJCardView) -> CGFloat {
        return DefaultDistanceRatioToCenterOfEdgeItem
    }
    
    public func angleRotationOfCenterItem(in cardView: HJCardView) -> CGFloat {
        return DefaultAngleRotationOfCenterItem
    }
    
    public func scalingRatioOfCenterItem(in cardView: HJCardView) -> CGFloat {
        return DefaultScalingRatioOfCenterItem
    }
    
    public func distanceRatioToCenterOfCenterItem(in cardView: HJCardView) -> CGFloat {
        return DefaultDistanceRatioToCenterOfCenterItem
    }
    
}
