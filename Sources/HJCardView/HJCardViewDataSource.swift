import Foundation

public protocol HJCardViewDataSource: AnyObject {
    
    /// return how many items would show in the card view
    func numberOfItems(in cardView: HJCardView) -> Int
    
    /**
     * The growth of index follows the direction from the head to the tail.
     *
     * index start from zero
     */
    func cardView(_ cardView: HJCardView, itemAt index: Int) -> HJCardViewItem
    
}
