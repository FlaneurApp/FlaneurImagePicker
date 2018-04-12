import UIKit
import FlaneurImagePicker

enum MenuOption: String {
    case imagePicker = "Present image picker"
    case preUploadProcessor = "Pre-Upload Processor Benchmark"
}

extension MenuOption {
    var cellDescriptor: TableViewCellDescriptor {
        return TableViewCellDescriptor(reuseIdentifier: "menuItem", configure: self.configureCell)
    }

    func configureCell(_ cell: MenuOptionCell) {
        cell.textLabel?.text = self.rawValue
    }
}

final class MenuOptionCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The root menu of demo options.
class MenuNavigationController: UINavigationController {
    let optionsViewController: ItemsViewController<MenuOption> = {
        let menuOptionItems: [MenuOption] = [
            .imagePicker,
            .preUploadProcessor
        ]
        let result = ItemsViewController<MenuOption>(items: menuOptionItems, cellDescriptor: { $0.cellDescriptor })
        result.navigationItem.title = "Flaneur Open Demos"
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers = [ optionsViewController ]

        optionsViewController.didSelect = { menuOption in
            switch menuOption {
            case .imagePicker:
                let demoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DemoImagePickerViewController")
                self.pushViewController(demoVC, animated: true)
            case .preUploadProcessor:
                self.pushViewController(BenchmarkProcessorViewController(), animated: true)
            }
        }
    }
}
