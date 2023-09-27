import Foundation

public protocol HJCardViewDelegate: AnyObject {
    
    //func cardView(_ cardView: HJCardView, didSelectedItemAtIndex: Int)
    
// setting for edge items
    
    /**
     * how many items can be displayed in one direction
     *
     * for example if the number is 3, the views will shows like
     * |item 1| |item2| |item3| |item2| |item1|, the items 3 would be the center item
     *
     * the default value is 5
     */
    func numberOfItemsInSingleDirection() -> Int
    
    /**
     * the rotation angle of the item located at the edge,
     * the center item's rotation angle is zero,
     * the remaining items are proportional to their distance to from the center item
     *
     * the default value is .pi/9.
     */
    func angleRotationOfEdgeItem() -> CGFloat
    
    /**
     * the scaling ratio of the edge items to the center item
     * the remaining items are proportional to their distance to from the center item
     *
     * the default value is 0.8
     */
    func scalingRatioOfEdgeItem() -> CGFloat
    
    /**
     * the ratio that ( edge item distance to center / half width of  the card view)
     * the remaining items are proportional to their distance to from the center item
     * zero means the center item overlap the edge items
     *
     * the default value is 0.8
     */
    func distanceRatioToCenterOfEdgeItem() -> CGFloat
    
    
// setting for center item
    
    /**
     * the angle to rotate when the center item is dragged to the edge
     *
     * the default value is .pi/6
     */
    func angleRotationOfCenterItem() -> CGFloat
    
    /**
     * the scaling ratio when the center item is dragged to the edge
     *
     * the default value is 0.6
     */
    func scalingRatioOfCenterItem() -> CGFloat
    
    /**
     * the ratio that (center item max distance to center while dragging / half width of the card view)
     *
     * the default value is 1.0
     */
    func distanceRatioToCenterOfCenterItem() -> CGFloat
    
}

let DefaultNumberOfItemsInSingleDirection: Int        = 5
let DefaultAngleRotationOfEdgeItem: CGFloat           = .pi/9
let DefaultScalingRatioOfEdgeItem: CGFloat            = 0.8
let DefaultDistanceRatioToCenterOfEdgeItem: CGFloat   = 0.8
let DefaultAngleRotationOfCenterItem: CGFloat         = .pi/6
let DefaultScalingRatioOfCenterItem: CGFloat          = 0.6
let DefaultDistanceRatioToCenterOfCenterItem: CGFloat = 1.0


extension HJCardViewDelegate {
    
    func numberOfItemsInSingleDirection() -> Int {
        return DefaultNumberOfItemsInSingleDirection
    }
    
    func angleRotationOfEdgeItem() -> CGFloat {
        return DefaultAngleRotationOfEdgeItem
    }
    
    func scalingRatioOfEdgeItem() -> CGFloat {
        return DefaultScalingRatioOfEdgeItem
    }
    
    func distanceRatioToCenterOfEdgeItem() -> CGFloat {
        return DefaultDistanceRatioToCenterOfEdgeItem
    }
    
    public func angleRotationOfCenterItem() -> CGFloat {
        return DefaultAngleRotationOfCenterItem
    }
    
    func scalingRatioOfCenterItem() -> CGFloat {
        return DefaultScalingRatioOfCenterItem
    }
    
    func distanceRatioToCenterOfCenterItem() -> CGFloat {
        return DefaultDistanceRatioToCenterOfCenterItem
    }
    
}
