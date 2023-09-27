import Foundation

public protocol HJCardViewDataSource: AnyObject {
    
    /// return how many items would show in the card view
    func numberOfItems(in cardView: HJCardView) -> Int
    
    func cardView(_ cardView: HJCardView, itemAt index: Int) -> HJCardViewItem
    
}
