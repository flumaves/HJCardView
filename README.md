# HJCardView

A view that shows a serious of Cards

The usage is similar to UITableView, only need to comply with HJCardViewDelegate and HJCardViewDataSource.
The appearance style of card view can be highly customized through delegate, such as placement direction, rotate angle, etc.
Please read the comments of the methods in delegate to learn how to use it.

## Usage
`
class SomeViewController: UIViewController {

    var cardView: HJCardView?
    
    override func viewDidLoad() {
        
        let cardView = HJCardView(frame: CGRect(x: 0, y: 200, width: UIScreen.main.bounds.size.width, height: 300))
        cardView.delegate = self
        cardView.dataSource = self
//        cardView.placementDirection = .vertical

        self.view.addSubview(cardView)
    }
}


extension SomeViewController: HJCardViewDataSource, HJCardViewDelegate {

    func itemSize(in cardView: HJCardView) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
    func centerItemDidSelected(in cardView: HJCardView) {
        print("center item did selected")
    }
    
    func numberOfItems(in cardView: HJCardView) -> Int {
        return 10
    }
    
    func cardView(_ cardView: HJCardView, itemAt index: Int) -> HJCardViewItem {
    
        let item = HJCardViewItem()
        item.backgroundColor = .random()

        return item
    }
}
`
