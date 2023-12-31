import UIKit

/// HJCardView
public class HJCardView: UIView {
    
    public var delegate: HJCardViewDelegate? {
        didSet {
            visiableItems.numberOfItemsInHeadDirection = numberOfItemsInHeadDirection()
            visiableItems.numberOfItemsInTailDirection = numberOfItemsInTailDirection()
        }
    }
    
    public var placementDirection: HJCardView.PlacementDirection = .horizontal
    
    public var dataSource: HJCardViewDataSource?
    
    /// items shows on the screen
    private var visiableItems: HJCardView.Items = Items()
    
    // save the ratio of items movement each time drag it
    private var itemsRatioHaveMoved: CGFloat = 0
    
    // reuse pool, do not destoryed the item immediately when the item remove from the screen, but is put into the reuse pool. When a new item needed, it would be searched base on the reuseID
    private var reusePool: HJReusePool = HJReusePool()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panItem(_:)))
        self.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapItem(_:)))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        if self.visiableItems.count() > 0 { return }

        addItems()
        setItemsDefaultDistanceToCenter()
    }
}


// MARK: public methods
extension HJCardView {
    
    /// get the reusable cell from the reuse pool accroding to the reuseID, if not, return nil
    public func dequeueReusableItemWith(identifier reuseID: String) -> HJCardViewItem? {
        return reusePool.itemWith(reuseID: reuseID)
    }
    
    /// card view reload data from data source
    public func reloadData() {
        for item in visiableItems {
            moveItemIntoReusePool(item)
        }
    
        addItems()
        setItemsDefaultDistanceToCenter()
    }
    
    /// card view update appearance accroding to delegate
    public func updateAppearance() {
        setItemsDefaultDistanceToCenter()
    }
}


// MARK: private methods
// set positions of items on the card view
extension HJCardView {
    
    private func setItemsDefaultDistanceToCenter() {
        
        updateItemsStatus()
        
        let spaceInTailItems = distanceToCenterOfEdgeItem() / CGFloat((numberOfItemsInTailDirection() - 1))
        let tailItems = self.visiableItems.itemsFromCenterToTail()
        
        for index in 0..<tailItems.count {
            let distance = CGFloat(index) * spaceInTailItems
            let item = tailItems[index]
            setItem(item, distanceToCenter: distance)
        }

        let spaceInHeadItems = distanceToCenterOfEdgeItem() / CGFloat((numberOfItemsInHeadDirection() - 1))
        let headItems = self.visiableItems.itemsFromCenterToHead()
        
        for index in 0..<headItems.count {
            let distance = CGFloat(index * -1) * spaceInHeadItems
            let item = headItems[index]
            setItem(item, distanceToCenter: distance)
        }
    }
    
    /**
     * set the distance from the item to the center and adjust the rotation angle/scaling...
     */
    private func setItem(_ item: HJCardViewItem, distanceToCenter distance: CGFloat) {
        
        let centerX = self.bounds.size.width / 2
        let centerY = self.bounds.size.height / 2
        
        let maxDistanceToCenter = item.status == .centerItem ? distanceToCenterOfCenterItem() : distanceToCenterOfEdgeItem()
        let minScaleRatio = item.status == .centerItem ? scalingRatioOfCenterItem() : scalingRatioOfEdgeItem()
        let maxRotateAngle = item.status == .centerItem ? angleRotationOfCenterItem() : angleRotationOfEdgeItem()
        
        // position
        switch placementDirection {
        case .horizontal:
            item.center.x = centerX + distance
            item.center.y = centerY
        case .vertical:
            item.center.x = centerX
            item.center.y = centerY + distance
        }
        
        // scale
        let scaleRatio = minScaleRatio + (1 - abs(distance) / maxDistanceToCenter) * (1 - minScaleRatio)
        let scaleMatrix = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        
        // rotate
        let rotateRatio = distance / maxDistanceToCenter
        let rotateAngle = maxRotateAngle * rotateRatio
        let rotateMatrix = CGAffineTransform(rotationAngle: rotateAngle)
        
        item.transform = scaleMatrix.concatenating(rotateMatrix)
        
        // zPosition
        if item.status == .edgeItem {
            item.layer.zPosition = -abs(distance)
        } else if item.status == .centerItem {
            let spaceBetweenItem = distanceToCenterOfEdgeItem() / CGFloat((numberOfItemsInBothDirection() - 1))
            
            item.layer.zPosition = -abs(distance) < -spaceBetweenItem ? -spaceBetweenItem : -abs(distance)
        }
    }
}


// gestures on card view
extension HJCardView {
    
    @objc private func tapItem(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        
        let point = sender.location(in: self)
        let viewsContainPoint = self.subViewsContain(point: point)
        for view in viewsContainPoint {
            if !view.isKind(of: HJCardViewItem.self) { continue }
            let item = view as! HJCardViewItem
            
            if item.status == .centerItem {
                self.delegate?.centerItemDidSelected(in: self)
                return
            }
        }
    }
    
    @objc private func panItem(_ sender: UIPanGestureRecognizer) {
        
        let panOffSet = sender.translation(in: self)
        let velocity = placementDirection == .horizontal ? sender.velocity(in: self).x : sender.velocity(in: self).y
        let center = placementDirection == .horizontal ? self.bounds.width / 2 : self.bounds.height / 2
        
        switch sender.state {
        case .changed:
            // calculate the length that remaining items should move based on the proportion of the distance moved by the center item to the maximum moving distance of the center item
            var distanceCenterItemMove = placementDirection == .horizontal ? panOffSet.x : panOffSet.y
            let maxDistanceCenterItemMove = distanceToCenterOfCenterItem()
            let distanceRatioCenterItem = distanceCenterItemMove / maxDistanceCenterItemMove
            var distanceOtherItemMove = distanceToCenterOfEdgeItem() / CGFloat(numberOfItemsInBothDirection() - 1) * distanceRatioCenterItem
            
            itemsRatioHaveMoved += distanceRatioCenterItem
            // set to 0.8 to slow down the item when it is about to move the maxmimum distance
            // distanceOtherItemMove = abs(itemsHaveMovedRatio) < 1 ? distanceOtherItemMove : 0
            distanceOtherItemMove = abs(itemsRatioHaveMoved) < 0.8 ? distanceOtherItemMove : distanceOtherItemMove / 5
            
            // add constraint while center item is the most marginal item
            if (itemsRatioHaveMoved > 0 && centerItemIsHeadItem()) || (itemsRatioHaveMoved < 0 && centerItemIsTailItem()) {
                distanceCenterItemMove = distanceCenterItemMove / 10
                distanceOtherItemMove = distanceOtherItemMove / 5
            }
            
            for item in self.visiableItems {
                let itemCenter = placementDirection == .horizontal ? item.center.x : item.center.y
                let distance = item.status == .centerItem ? itemCenter - center + distanceCenterItemMove : itemCenter - center + distanceOtherItemMove
                setItem(item, distanceToCenter: distance)
            }
            
            sender.setTranslation(CGPoint.zero, in: self)

        case .ended:
            
            defer {
                UIView.animate(withDuration: 0.25) {
                    self.setItemsDefaultDistanceToCenter()
                }
            }
            
            itemsRatioHaveMoved = 0
            
            // determine whether to update or restore based on the proportion of center item movement
            guard let centerItem = self.visiableItems.centerItem()?.item else { return }
            let centerItemCenter = placementDirection == .horizontal ? centerItem.center.x : centerItem.center.y
            let ratio = (centerItemCenter - center) / distanceToCenterOfCenterItem()
            
            // move one step to the head/tail
            if ratio <= -0.8 || velocity < -500 {
                if let centerItemIndex = self.visiableItems.centerItem()?.index, centerItemIndex + 1 < numberOfItemsInCardView() {
                    if let delelteItem = self.visiableItems.allItemsMoveHead() {
                        delelteItem.removeFromSuperview()
                    }
                }
                
                if let tailItemWithIndex = self.visiableItems.tailItem() {
                    let newItemIndex = tailItemWithIndex.index + 1
                    
                    guard let newItem = itemIn(index: newItemIndex) else { return }
                    let newItemWithIndex = ItemWithIndex(item: newItem, index: newItemIndex)
                    
                    let spaceInTailItems = distanceToCenterOfEdgeItem() / CGFloat((numberOfItemsInTailDirection() - 1))
                    var distance = CGFloat(visiableItems.itemsFromCenterToTail().count - 1) * spaceInTailItems
                    distance = distance > 0 ? distance : 0
                    
                    setItem(newItem, distanceToCenter: distance)
                    newItem.layer.zPosition = -1000
                    newItem.transform = newItem.transform.concatenating(CGAffineTransform(scaleX: 0.9, y: 0.9))
                    
                    self.addSubview(newItem)
                    self.visiableItems.addItemToTail(newItemWithIndex)
                }
            
            } else if ratio >= 0.8 || velocity > 500 {
                if let centerItemIndex = self.visiableItems.centerItem()?.index, centerItemIndex - 1 >= 0 {
                    if let deleteItem = self.visiableItems.allItemsMoveTail() {
                        deleteItem.removeFromSuperview()
                    }
                }
                
                if let headItemWithIndex = self.visiableItems.headItem() {
                    let newItemIndex = headItemWithIndex.index - 1
                    
                    guard let newItem = itemIn(index: newItemIndex) else { return }
                    let newItemWithIndex = ItemWithIndex(item: newItem, index: newItemIndex)
                    
                    let spaceInHeadItems = distanceToCenterOfEdgeItem() / CGFloat((numberOfItemsInHeadDirection() - 1))
                    var distance = CGFloat(visiableItems.itemsFromCenterToHead().count - 1) * spaceInHeadItems
                    distance = distance > 0 ? distance : 0
                    
                    setItem(newItem, distanceToCenter: -distance)
                    newItem.layer.zPosition = -1000
                    newItem.transform = newItem.transform.concatenating(CGAffineTransform(scaleX: 0.9, y: 0.9))
                    
                    self.addSubview(newItem)
                    self.visiableItems.addItemToHead(newItemWithIndex)
                }
            }
        default:
            break
        }
    }
    
}


// data structrue of card view
extension HJCardView {
    
    // item with index of all items, index start from zero
    private struct ItemWithIndex: Equatable {
        var item: HJCardViewItem
        var index: Int
    }
    
    private class Node: Equatable {
        
        var preNode: Node?
        var nextNode: Node?
        
        var itemWithIndex: ItemWithIndex?   // sentinel item is equal nil
        
        init(preNode: Node? = nil, nextNode: Node? = nil, itemWithIndex: ItemWithIndex? = nil) {
            self.preNode = preNode
            self.nextNode = nextNode
            self.itemWithIndex = itemWithIndex
        }
        
        static func == (lhs: Node, rhs: Node) -> Bool {
            return lhs.itemWithIndex == rhs.itemWithIndex
        }
        
        init() {}
    }
    
    /**
     * this is a double linked list with two sentinel
     * centerNode point to the center item with index which showing on the screen, if dont have items it would be nil
     */
    private class Items: Sequence {
        
        private let headSentinel: Node = Node()
        private let tailSentinel: Node = Node()
        private var centerNode: Node?
        
        var numberOfItemsInHeadDirection: Int
        var numberOfItemsInTailDirection: Int

        init(numberOfItemsInHeadDirection: Int = DefaultNumberOfItemsInBothDirection, numberOfItemsInTailDirection: Int = DefaultNumberOfItemsInBothDirection) {
            self.numberOfItemsInHeadDirection = numberOfItemsInHeadDirection
            self.numberOfItemsInTailDirection = numberOfItemsInTailDirection
            
            self.headSentinel.nextNode = tailSentinel
            self.tailSentinel.preNode = headSentinel
        }
        
        // return number of items(showing on screen) in card view
        func count() -> Int {
            var count = 0
            var curNode = headSentinel
            
            while let node = curNode.nextNode, node != tailSentinel {
                count += 1
                curNode = node
            }
            
            return count
        }
        
        // add item to the head/tail of card view
        func addItemToHead(_ item: ItemWithIndex) {
            let node = Node(itemWithIndex: item)
            
            let nextNode = self.headSentinel.nextNode
            
            nextNode?.preNode = node
            node.preNode = headSentinel
            headSentinel.nextNode = node
            node.nextNode = nextNode
            
            if centerNode == nil {
                self.centerNode = node
            }
        }

        func addItemToTail(_ item: ItemWithIndex) {
            let node = Node(itemWithIndex: item)
            
            let preNode = self.tailSentinel.preNode
            
            preNode?.nextNode = node
            node.nextNode = tailSentinel
            tailSentinel.preNode = node
            node.preNode = preNode
            
            if centerNode == nil {
                self.centerNode = node
            }
        }
        
        // delete head/tail item in card view and return the item
        func deleteHeadItem() -> HJCardViewItem? {
            guard centerNode != nil else { return nil }
            
            let deleteNode = self.headSentinel.nextNode
            let nextNode = deleteNode?.nextNode
            
            self.headSentinel.nextNode = nextNode
            nextNode?.preNode = self.headSentinel
            
            return deleteNode?.itemWithIndex?.item
        }
        
        func deleteTailItem() -> HJCardViewItem? {
            guard centerNode != nil else { return nil }
            
            let deleteNode = self.tailSentinel.preNode
            let preNode = deleteNode?.preNode
            
            self.tailSentinel.preNode = preNode
            preNode?.nextNode = self.tailSentinel
            
            return deleteNode?.itemWithIndex?.item
        }
        
        /*
         * all items move one step to the head/tail
         * if the number of items on head/tail exceeds number of items corresponding to the direction, the most head/tail item will be deleted and returned
         */
        func allItemsMoveHead() -> HJCardViewItem? {
            guard let newCenterNode = self.centerNode?.nextNode else { return nil }
            
            self.centerNode = newCenterNode
            
            if itemsFromCenterToHead().count > numberOfItemsInHeadDirection {
                return deleteHeadItem()
            }
            
            return nil
        }
        
        func allItemsMoveTail() -> HJCardViewItem? {
            guard let newCenterNode = self.centerNode?.preNode else { return nil }
            
            self.centerNode = newCenterNode
            
            if itemsFromCenterToTail().count > numberOfItemsInTailDirection {
                return deleteTailItem()
            }
            
            return nil
        }
        
        // return all items to the head/tail including the center item
        func itemsFromCenterToHead() -> [HJCardViewItem] {
            var items: [HJCardViewItem] = []
            
            var curNode = centerNode
            
            while let node = curNode, let itemWithIndex = node.itemWithIndex {
                items.append(itemWithIndex.item)
                curNode = node.preNode
            }
            
            return items
        }

        func itemsFromCenterToTail() -> [HJCardViewItem] {
            var items: [HJCardViewItem] = []
            
            var curNode = centerNode
            
            while let node = curNode, let itemWithIndex = node.itemWithIndex {
                items.append(itemWithIndex.item)
                curNode = node.nextNode
            }
            
            return items
        }
        
        // return all items except center item
        func itemsExceptCenterItem() -> [HJCardViewItem] {
            var items:[HJCardViewItem] = []
            
            var curNode = self.headSentinel.nextNode
            
            while let node = curNode, let itemWithIndex = node.itemWithIndex {
                if self.centerNode != node {
                    items.append(itemWithIndex.item)
                }
                curNode = node.nextNode
            }
            
            return items
        }
        
        // return center item
        func centerItem() -> ItemWithIndex? {
            return self.centerNode?.itemWithIndex
            
        }
        
        // return the item closest to the center item at the head/tail
        func centerHeadItem() -> ItemWithIndex? {
            return self.centerNode?.preNode?.itemWithIndex
        }

        func centerTailItem() -> ItemWithIndex? {
            return self.centerNode?.nextNode?.itemWithIndex
        }
        
        /*
         * return the most head/tail item
         * return item with index because it would be used in code
         */
        func tailItem() -> ItemWithIndex? {
            return self.tailSentinel.preNode?.itemWithIndex
        }
        
        func headItem() -> ItemWithIndex? {
            return self.headSentinel.nextNode?.itemWithIndex
        }
        
        func makeIterator() -> AnyIterator<HJCardViewItem> {
            var curNode = headSentinel.nextNode
            
            return AnyIterator {
                defer { curNode = curNode?.nextNode }
                return curNode?.itemWithIndex?.item
            }
        }
    }
}


// reuse pool for card view
extension HJCardView {
    private class HJReusePool {
        lazy var reusePool: [String: [HJCardViewItem]] = [:]
        
        func itemWith(reuseID: String) -> HJCardViewItem? {
            if reusePool[reuseID]?.count != 0 {
                let item = reusePool[reuseID]?.removeLast()
                return item
            }
            
            return nil
        }
        
        func add(item: HJCardViewItem, with reuseID: String) {
            if reusePool[reuseID] != nil {
                reusePool[reuseID]?.append(item)
            } else {
                let newIDArray = [item]
                reusePool[reuseID] = newIDArray
            }
        }
    }
}


extension HJCardView {

    private func itemSize() -> CGSize {
        if let delegate = delegate, delegate.itemSize(in: self) != CGSize.zero {
            return delegate.itemSize(in: self)
        }
        // default item size
        let itemH = self.frame.height * 0.8, itemW = itemH * 3 / 4
        return CGSize(width: itemW, height: itemH)
    }
    
//    private func centerItemSize() -> CGSize {
//        if let delegate = delegate, delegate.centerItemSize(in: self) != CGSize.zero {
//            return delegate.centerItemSize(in: self)
//        }
//        
//        return itemSize()
//    }
    
    private func numberOfItemsInHeadDirection() -> Int {
        return delegate?.numberOfItemsInHeadDirection(in: self) ?? DefaultNumberOfItemsInBothDirection
    }
    
    private func numberOfItemsInTailDirection() -> Int {
        return delegate?.numberOfItemsInTailDirection(in: self) ?? DefaultNumberOfItemsInBothDirection
    }
    
    private func numberOfItemsInBothDirection() -> Int {
        return delegate?.numberOfItemsInBothDirection(in: self) ?? DefaultNumberOfItemsInBothDirection
    }
    
    private func angleRotationOfEdgeItem() -> CGFloat {
        return delegate?.angleRotationOfEdgeItem(in: self) ?? DefaultAngleRotationOfEdgeItem
    }
    
    private func scalingRatioOfEdgeItem() -> CGFloat {
        return delegate?.scalingRatioOfEdgeItem(in: self) ?? DefaultScalingRatioOfEdgeItem
    }
    
    private func distanceRatioToCenterOfEdgeItem() -> CGFloat {
        return delegate?.distanceRatioToCenterOfEdgeItem(in: self) ?? DefaultDistanceRatioToCenterOfEdgeItem
    }
    
    private func distanceToCenterOfEdgeItem() -> CGFloat {
        let halfWidth = self.bounds.width / 2
        return halfWidth * distanceRatioToCenterOfEdgeItem()
    }
    
    private func angleRotationOfCenterItem() -> CGFloat {
        return delegate?.angleRotationOfCenterItem(in: self) ?? DefaultAngleRotationOfCenterItem
    }
    
    private func scalingRatioOfCenterItem() -> CGFloat {
        return delegate?.scalingRatioOfCenterItem(in: self) ?? DefaultScalingRatioOfCenterItem
    }
    
    private func distanceRatioToCenterOfCenterItem() -> CGFloat {
        return delegate?.distanceRatioToCenterOfCenterItem(in: self) ?? DefaultDistanceRatioToCenterOfCenterItem
    }
    
    private func distanceToCenterOfCenterItem() -> CGFloat {
        let halfWidth = self.bounds.width / 2
        return halfWidth * distanceRatioToCenterOfCenterItem()
    }
    
    private func numberOfItemsInCardView() -> Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }
}


extension HJCardView {
    
    private func updateItemsStatus() {
        guard let centerItem = visiableItems.centerItem()?.item else {
            return
        }
        
        for item in self.visiableItems {
            if item == centerItem {
                item.status = .centerItem
            } else {
                item.status = .edgeItem
            }
        }
    }
    
    // return whether the center item is the head/tail item in data source
    private func centerItemIsHeadItem() -> Bool {
        return visiableItems.centerItem()?.index == 0
    }
    
    private func centerItemIsTailItem() -> Bool {
        return visiableItems.centerItem()?.index == numberOfItemsInCardView() - 1
    }
    
    // add item into reuse pool and remove item from card view at the same time
    private func moveItemIntoReusePool(_ item: HJCardViewItem) {
        item.removeFromSuperview()
        
        reusePool.add(item: item, with: (item.reuseID != nil) ? item.reuseID! : "ReuseID_Nil")
    }
    
    // get item in index from data Source, if dataSource is nil, return nil
    private func itemIn(index: Int) -> HJCardViewItem? {
        guard let dataSource = dataSource else { return nil }
        if index < 0 || index > numberOfItemsInCardView() { return nil }
        
        let item = dataSource.cardView(self, itemAt: index)
        item.frame.size = itemSize()
        item.status = .newItem
        
        switch placementDirection {
        case .horizontal:
            item.frame.origin.y = self.bounds.origin.y
        case .vertical:
            item.frame.origin.x = self.bounds.origin.x
        }

        return item
    }
    
    // the method would be call when card view load data, at this time, visiableItems is empty
    private func addItems() {
        for index in 0..<(numberOfItemsInHeadDirection() + numberOfItemsInTailDirection() - 1) {
            guard let item = itemIn(index: index) else { break }

            self.sendSubviewToBack(item)
            self.addSubview(item)
            
            let itemWithIndex = ItemWithIndex(item: item, index: index)
            self.visiableItems.addItemToTail(itemWithIndex)
        }
    }
}


// card view config
extension HJCardView {
    
    public enum PlacementDirection {
        case horizontal
        case vertical
    }
}


extension UIView {
    
    public func subViewsContain(point: CGPoint) -> [UIView] {
        var result: [UIView] = []
        
        for subView in self.subviews {
            if CGRectContainsPoint(subView.frame, point) {
                result.append(subView)
            }
        }
        
        return result
    }
}
