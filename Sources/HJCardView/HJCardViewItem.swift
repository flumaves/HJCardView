import UIKit


public class HJCardViewItem: UIView {
    
    var status: HJCardViewItemStatu = .none
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 15.0
        self.backgroundColor = .systemGray
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.clipsToBounds = true
        
        self.status = .newItem
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
