import Foundation

public protocol HJCardViewDelegate: AnyObject {
    
    //func cardView(_ cardView: HJCardView, didSelectedItemAtIndex: Int)
    
    /// the size of the item closest to the center item
    func itemSize(of cardView: HJCardView) -> CGSize
    
    /**
     * the size of the center item
     *
     * when the method 'centerItemSize(of:)' isn't implemented, the size of the center item is equal to the item size
     */
    func centerItemSize(of cardView: HJCardView) -> CGSize
    
    
// setting for edge items
    
    /**
     * how many items can be displayed in one direction
     *
     * for example if the number is 3, the views will shows like
     * |item 1| |item2| |item3| |item2| |item1|, the items 3 would be the center item
     *
     * the default value is 5
     */
    func numberOfItemsInSingleDirection(of cardView: HJCardView) -> Int
    
    /**
     * the rotation angle of the item located at the edge,
     * the center item's rotation angle is zero,
     * the remaining items are proportional to their distance to from the center item
     *
     * the default value is .pi/9.
     */
    func angleRotationOfEdgeItem(of CardView: HJCardView) -> CGFloat
    
    /**
     * the scaling ratio of the edge items to the center item
     * the remaining items are proportional to their distance to from the center item
     *
     * the default value is 0.8
     */
    func scalingRatioOfEdgeItem(of cardView: HJCardView) -> CGFloat
    
    /**
     * the ratio that ( edge item distance to center / half width of  the card view)
     * the remaining items are proportional to their distance to from the center item
     * zero means the center item overlap the edge items
     *
     * the default value is 0.8
     */
    func distanceRatioToCenterOfEdgeItem(of cardView: HJCardView) -> CGFloat
    
    
// setting for center item
    
    /**
     * the angle to rotate when the center item is dragged to the edge
     *
     * the default value is .pi/6
     */
    func angleRotationOfCenterItem(of cardView: HJCardView) -> CGFloat
    
    /**
     * the scaling ratio when the center item is dragged to the edge
     *
     * the default value is 0.8
     */
    func scalingRatioOfCenterItem(of cardView: HJCardView) -> CGFloat
    
    /**
     * the ratio that (center item max distance to center while dragging / half width of the card view)
     *
     * the default value is 1.0
     */
    func distanceRatioToCenterOfCenterItem(of cardView: HJCardView) -> CGFloat
}

let DefaultNumberOfItemsInSingleDirection: Int        = 5
let DefaultAngleRotationOfEdgeItem: CGFloat           = .pi/9
let DefaultScalingRatioOfEdgeItem: CGFloat            = 0.8
let DefaultDistanceRatioToCenterOfEdgeItem: CGFloat   = 0.8
let DefaultAngleRotationOfCenterItem: CGFloat         = .pi/6
let DefaultScalingRatioOfCenterItem: CGFloat          = 0.8
let DefaultDistanceRatioToCenterOfCenterItem: CGFloat = 1.0


extension HJCardViewDelegate {
    
    public func itemSize(of cardView: HJCardView) -> CGSize {
        return CGSize.zero
    }
    
    public func centerItemSize(of cardView: HJCardView) -> CGSize {
        return itemSize(of: cardView)
    }
    
    public func numberOfItemsInSingleDirection(of cardView: HJCardView) -> Int {
        return DefaultNumberOfItemsInSingleDirection
    }
    
    public func angleRotationOfEdgeItem(of cardView: HJCardView) -> CGFloat {
        return DefaultAngleRotationOfEdgeItem
    }
    
    public func scalingRatioOfEdgeItem(of cardView: HJCardView) -> CGFloat {
        return DefaultScalingRatioOfEdgeItem
    }
    
    public func distanceRatioToCenterOfEdgeItem(of cardView: HJCardView) -> CGFloat {
        return DefaultDistanceRatioToCenterOfEdgeItem
    }
    
    public func angleRotationOfCenterItem(of cardView: HJCardView) -> CGFloat {
        return DefaultAngleRotationOfCenterItem
    }
    
    public func scalingRatioOfCenterItem(of cardView: HJCardView) -> CGFloat {
        return DefaultScalingRatioOfCenterItem
    }
    
    public func distanceRatioToCenterOfCenterItem(of cardView: HJCardView) -> CGFloat {
        return DefaultDistanceRatioToCenterOfCenterItem
    }
    
}
