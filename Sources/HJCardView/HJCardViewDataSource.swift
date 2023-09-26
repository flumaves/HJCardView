import Foundation

public protocol HJCardViewDataSource {
    
    /// return how many items would show in the card view
    func numberOfItemsInCardView() -> Int
    
    func cardView(_ cardView: HJCardView, itemForIndex: Int) -> HJCardViewItem
    
}
