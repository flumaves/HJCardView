import UIKit


public class HJCardViewItem: UIView {
    
    var status: HJCardViewItemStatu = .none
    
    var reuseID: String?
    
    public init(withReuseIdentifier reuseID: String? = nil) {
        super.init(frame: CGRectZero)
        
        self.layer.cornerRadius = 15.0
        self.backgroundColor = .systemGray
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.clipsToBounds = true
        
        self.status = .newItem
        self.reuseID = reuseID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension HJCardViewItem {
    
    enum HJCardViewItemStatu {
        case newItem
        case edgeItem
        case centerItem
        case none
    }
}
