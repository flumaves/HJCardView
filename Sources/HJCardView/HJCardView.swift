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
    
    private var panAction: UIPanGestureRecognizer?
    
    /// items shows on the screen
    private var visiableItems = Items()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panItem(_:)))
        self.addGestureRecognizer(pan)
        self.panAction = pan
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        
        if self.visiableItems.count() > 0 { return }
        
        guard let dataSource = self.dataSource else { return }
        
        for index in 0..<numberOfItemsInBothDirection() {
            let item = dataSource.cardView(self, itemAt: index)
            item.bounds.size = itemSize()
            item.frame.origin.y = self.bounds.origin.y
            
            self.sendSubviewToBack(item)
            self.addSubview(item)
            
            let itemWithIndex = ItemWithIndex(item: item, index: index)
            self.visiableItems.addItemToTail(itemWithIndex)
        }
        
        setItemsDistanceToCenter()
    }
}

extension HJCardView {
    
    // set items distance to center
    private func setItemsDistanceToCenter() {
        
        let spaceBetweenItem = distanceToCenterOfEdgeItem() / CGFloat((numberOfItemsInBothDirection() - 1))

        let rightItems = self.visiableItems.itemsFromCenterToTail()
        
        for index in 0..<rightItems.count {
            let distance = CGFloat(index) * spaceBetweenItem
            let item = rightItems[index]
            setItem(item, distanceToCenter: distance)
        }

        let leftItems = self.visiableItems.itemsFromCenterToHead()
        
        for index in 0..<leftItems.count {
            let distance = CGFloat(index * -1) * spaceBetweenItem
            let item = leftItems[index]
            setItem(item, distanceToCenter: distance)
        }
    }
    
    /**
     * set the distance from the item to the center and adjust the rotation angle/scaling...
     */
    private func setItem(_ item: HJCardViewItem, distanceToCenter distance: CGFloat) {
        
        let centerX = self.bounds.size.width / 2
        let centerY = self.bounds.size.height / 2
        
        let maxDistanceToCenter = distanceToCenterOfEdgeItem()
        let minScaleRatio = scalingRatioOfEdgeItem()
        let maxRotateAngle = angleRotationOfEdgeItem()
        
        // position
        item.center.x = centerX + distance
        item.center.y = centerY
        
        // scale
        let scaleRatio = minScaleRatio + (1 - abs(distance) / maxDistanceToCenter) * (1 - minScaleRatio)
        let scaleMatrix = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        
        // rotate
        let rotateRatio = distance / maxDistanceToCenter
        let rotateAngle = maxRotateAngle * rotateRatio
        let rotateMatrix = CGAffineTransform(rotationAngle: rotateAngle)
        
        item.transform = scaleMatrix.concatenating(rotateMatrix)
        
        // zPosition
        item.layer.zPosition = -abs(distance)
    }

    private func setCenterItem(_ item: HJCardViewItem, distanceToCenter distance: CGFloat) {
        
        let centerX = self.bounds.size.width / 2
        let centerY = self.bounds.size.height / 2
        
        let maxDistanceToCenter = distanceToCenterOfCenterItem()
        let minScaleRatio = scalingRatioOfCenterItem()
        let maxRotateAngle = angleRotationOfCenterItem()
        
        // position
        item.center.x = centerX + distance
        item.center.y = centerY
        
        // scale
        let scaleRatio = minScaleRatio + (1 - abs(distance) / maxDistanceToCenter) * (1 - minScaleRatio)
        let scaleMatrix = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        
        // rotate
        let rotateRatio = distance / maxDistanceToCenter
        let rotateAngle = maxRotateAngle * rotateRatio
        let rotateMatrix = CGAffineTransform(rotationAngle: rotateAngle)
        
        item.transform = scaleMatrix.concatenating(rotateMatrix)
        
        // zPosition
        //        item.layer.zPosition = -abs(distance)
    }
    
    private func setNewItem(_ item: HJCardViewItem, distanceToCenter distance: CGFloat) {
        
        let centerX = self.bounds.size.width / 2
        let centerY = self.bounds.size.height / 2
        
        let maxDistanceToCenter = distanceToCenterOfEdgeItem()
        let minScaleRatio = scalingRatioOfEdgeItem()
        let maxRotateAngle = angleRotationOfEdgeItem()
        
        // position
        item.center.x = centerX + distance
        item.center.y = centerY
        
        // scale
        let scaleRatio = minScaleRatio + (1 - abs(distance) / maxDistanceToCenter) * (1 - minScaleRatio)
        let scaleMatrix = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        
        // rotate
        let rotateRatio = distance / maxDistanceToCenter
        let rotateAngle = maxRotateAngle * rotateRatio
        let rotateMatrix = CGAffineTransform(rotationAngle: rotateAngle)
        
        item.transform = scaleMatrix.concatenating(rotateMatrix)
    }
}

extension HJCardView {

    @objc private func panItem(_ sender: UIPanGestureRecognizer) {
        
        let panOffSet = sender.translation(in: self)
        let center = self.bounds.width / 2
        
        if sender.state == .changed {
            let otherItems = self.visiableItems.itemsExceptCenterItem()
            
            // calculate the length that remaining items should move based on the proportion of the distance moved by the center item to the maximum moving distance of the center item
            let maxDistanceCenterItemMove = distanceToCenterOfCenterItem()
            let distanceRatioCenterItem = panOffSet.x / maxDistanceCenterItemMove / 1.5
            let distanceOtherItemMove = distanceToCenterOfEdgeItem() / CGFloat(numberOfItemsInBothDirection() - 1) * distanceRatioCenterItem
            
            for item in otherItems {
                let distance = item.center.x + distanceOtherItemMove - center
                setItem(item, distanceToCenter: distance)
            }

            if let centerItem = self.visiableItems.centerItem() {
                let distance = centerItem.item.center.x - center + panOffSet.x
                setCenterItem(centerItem.item, distanceToCenter: distance)
            }
            
            sender.setTranslation(CGPoint.zero, in: self)
            
        } else if sender.state == .ended {
            
            // determine whether to update or restore based on the proportion of center item movement
            guard let centerItem = self.visiableItems.centerItem() else { return }
            let ratio = (centerItem.item.center.x - center) / distanceToCenterOfCenterItem()
            
            // move one step to the left
            if ratio <= -0.9 {
                if let centerItemIndex = self.visiableItems.centerItem()?.index, centerItemIndex + 1 < numberOfItemsInCardView() {
                    if let delelteItem = self.visiableItems.allItemsMoveLeft() {
                        delelteItem.removeFromSuperview()
                    }
                }
                
                if let farRightItemIndex = self.visiableItems.tailItem()?.index, farRightItemIndex + 1 < numberOfItemsInCardView() {
                    
                    let newItemIndex = farRightItemIndex + 1
                    
                    if let dataSource = self.dataSource {
                        let newItem = dataSource.cardView(self, itemAt: newItemIndex)
                        newItem.frame.size = itemSize()
                        let newItemWithIndex = ItemWithIndex(item: newItem, index: newItemIndex)
                        
                        let farRightItem = self.visiableItems.tailItem()!.item
                        let distance = farRightItem.center.x
                        
                        setNewItem(newItem, distanceToCenter: 30)
                        newItem.layer.zPosition = -1000
                        newItem.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.addSubview(newItem)
                        
                        UIView.animate(withDuration: 0.25) {
                            self.setNewItem(newItem, distanceToCenter: distance)
                            self.setItemsDistanceToCenter()
                        }
                        
                        self.visiableItems.addItemToTail(newItemWithIndex)
                    }
                }
            
            // move one step to the right
            } else if ratio >= 0.9 {
                if let centerItemIndex = self.visiableItems.centerItem()?.index, centerItemIndex - 1 >= 0 {
                    if let deleteItem = self.visiableItems.allItemsMoveRight() {
                        deleteItem.removeFromSuperview()
                    }
                }
                
                if let farLeftItemIndex = self.visiableItems.headItem()?.index, farLeftItemIndex - 1 >= 0 {
                    
                    let newItemIndex = farLeftItemIndex - 1
                    
                    if let dataSource = self.dataSource {
                        let newItem = dataSource.cardView(self, itemAt: newItemIndex)
                        newItem.frame.size = itemSize()
                        let newItemWithIndex = ItemWithIndex(item: newItem, index: newItemIndex)
                        
                        let farLeftItem = self.visiableItems.headItem()!.item
                        let distance = farLeftItem.center.x
                        
                        setNewItem(newItem, distanceToCenter: -30)
                        newItem.layer.zPosition = -1000
                        newItem.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.addSubview(newItem)
                        
                        UIView.animate(withDuration: 0.25) {
                            self.setNewItem(newItem, distanceToCenter: distance)
                            self.setItemsDistanceToCenter()
                        }
                        
                        self.visiableItems.addItemToHead(newItemWithIndex)
                    }
                }
            }
            
            UIView.animate(withDuration: 0.25) {
                self.setItemsDistanceToCenter()
            }
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
    private class Items {
        
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
        func allItemsMoveLeft() -> HJCardViewItem? {
            guard let newCenterNode = self.centerNode?.nextNode else { return nil }
            
            self.centerNode = newCenterNode
            
            if itemsFromCenterToHead().count > numberOfItemsInHeadDirection {
                return deleteHeadItem()
            }
            
            return nil
        }
        
        func allItemsMoveRight() -> HJCardViewItem? {
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
        func headItem() -> ItemWithIndex? {
            return self.tailSentinel.preNode?.itemWithIndex
        }
        
        func tailItem() -> ItemWithIndex? {
            return self.headSentinel.nextNode?.itemWithIndex
        }
    }
}

extension HJCardView {

    private func itemSize() -> CGSize {
        if let delegate = delegate, delegate.itemSize(in: self) != CGSize.zero {
            return delegate.itemSize(in: self)
        }
        
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
    
    public enum PlacementDirection {
        case horizontal
        case vertical
    }
    
}

public class HJCardViewItem: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 15.0
        self.backgroundColor = .systemGray
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
