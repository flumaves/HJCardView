import Foundation

public protocol HJCardViewDelegate {
    
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
