//
//  RegistrationTableViewModel.swift
//  Registration
//
//  Created by Xinyuan_Wang on 2023/8/20.
//

import Foundation
import UIKit

enum Section: CaseIterable {
    case main
}

enum MyTableCellType: String, CaseIterable {
    case pictureShowable, selectable, singleClickable, inputable
}

protocol DetailDescribable {
    
}

struct MyRegistrationInfo: CustomStringConvertible {
    enum Keys: String, CaseIterable {
        case firstName = "First Name", avatar = "Avatar", lastName = "Last Name", phoneNumber = "Phone Number", email = "Email", selectedColor = "Custom Avatar Color"
        static var allCases: [MyRegistrationInfo.Keys] {
            return [.avatar, .firstName, .lastName, phoneNumber, .email, .selectedColor]
        }
    }
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let avatar: UIImage?
    let selectedColor: String?
    
    var description: String {
        """
\(Keys.firstName):\(firstName)
\(Keys.lastName):\(lastName)
\(Keys.phoneNumber):\(phoneNumber)
\(Keys.email):\(email)
\(avatar == nil ? "No" : "Has") avatar
\(Keys.selectedColor):\(selectedColor ?? "")
"""
    }
}

class MyTableModel: Hashable {
    static func == (lhs: MyTableModel, rhs: MyTableModel) -> Bool {
       return lhs.hashValue == rhs.hashValue
    }
    
    let type: MyTableCellType
    let title: String
    let hint: String
    var detail: DetailDescribable?
    
    init(type: MyTableCellType, title: String, hint: String, detail: String? = nil) {
        self.type = type
        self.title = title
        self.hint = hint
        self.detail = detail
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        if !title.isEmpty {
            hasher.combine(title)
        }
        if !hint.isEmpty {
            hasher.combine(hint)
        }
    }
}

class MyDetailModel:DetailDescribable {
    var image: UIImage?
    var color: UIColor?
}

class RegistrationTableViewModel {
    
    weak var targetTable: UITableView?
    weak var controller: UIViewController?
    
    var cellData: [MyTableModel] = []
    
    private var _dataSource: UITableViewDiffableDataSource<Section, MyTableModel>?
    var dataSource: UITableViewDiffableDataSource<Section, MyTableModel>? {
        get {
            return _dataSource
        }
    }
    
    init(with tableView: UITableView) {
        self.targetTable = tableView
        _dataSource = UITableViewDiffableDataSource<Section, MyTableModel>(tableView: tableView) {[weak self] tableView, indexPath, itemModel in
            guard let self = self else {
                return nil
            }
            return self.cell(tableView, with: itemModel, at: indexPath)
        }
    }
    
    func event(for cell: RegistrationTableCell) {
        if let index = targetTable?.indexPath(for: cell) {
            let model = cellData[index.row]
            switch model.type {
            case .pictureShowable:
                self.showImagePicker { image in
                    let detail = model.detail as? MyDetailModel ?? MyDetailModel()
                    detail.image = image
                    model.detail = detail
                    self.cellData[index.row] = model
                    self.reloadItem([model])
                }
                break
            case .inputable:
                if let realCell = cell as? RegistrationTextFieldTableCell{
                    let current = model.detail
                    model.detail = realCell.textField?.text ?? current
                }
            case .selectable:
                self.showColorPicker(inCell: cell) { color in
                    var items = [model]
                    model.detail = color?.hexRepresentation
                    if let avatar = self.cellData.first(where: { $0.type == .pictureShowable }) {
                       let detail = (avatar.detail as? MyDetailModel) ?? MyDetailModel()
                        detail.color = color
                        avatar.detail = detail
                        items.insert(avatar, at: 0)
                    }
                    self.reloadItem(items)
                }
            case .singleClickable:
                self.formRegistratinInfoAndSubmit(data: cellData)
            }
        }
    }
    
    func showImagePicker(completion: @escaping ((UIImage)->Void)) {
        if let controller = self.controller as? RegistrationViewController {
            controller .presentImagePicker { image in
                //TODO: upload image data with URL
                completion(image)
            }
        }
    }
    
    func showColorPicker(inCell cell: RegistrationTableCell, completion: @escaping ((UIColor?)->Void)) {
        if let realCell = cell as? RegistrationSelectableTableCell,
           let controller = self.controller as? RegistrationViewController {
            controller.presentColorPicker(fromSource: realCell.button, completion: completion)
        }
    }
    
    func formRegistratinInfoAndSubmit(data: [MyTableModel]) {
        let info = MyRegistrationInfo(firstName: data[1].detail as? String ?? "",
                                      lastName: data[2].detail as? String ?? "",
                                      phoneNumber: data[3].detail as? String ?? "",
                                      email: data[4].detail as? String ?? "",
                                      avatar: (data[0].detail as? MyDetailModel)?.image,
                                      selectedColor: data[5].detail as? String)
        let alert = UIAlertController(title: "Result", message: "\(info)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style:.cancel))
        self.controller?.present(alert, animated: true)
    }
    
    func loadAll(_ data: [MyTableModel]) {
        self.cellData = data;
        data.forEach { model in
            let cellClass = self.cell(for: model.type)
            self.targetTable?.register(cellClass, forCellReuseIdentifier: model.type.rawValue)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, MyTableModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        _dataSource?.apply(snapshot)
    }
    
    func reloadItem(_ data: [MyTableModel]) {
        if var snapshot = _dataSource?.snapshot() {
            snapshot.reloadItems(data)
            _dataSource?.apply(snapshot)
        }
    }
    
    func height(for index: IndexPath) -> CGFloat {
        guard index.row < cellData.count else { return 20 }
        switch cellData[index.row].type {
        case .pictureShowable:
            return 100
        default:
            return 80.0
        }
    }
    
    private func cell(_ table: UITableView, with model: MyTableModel, at index: IndexPath) -> UITableViewCell? {
        let cell = table.dequeueReusableCell(withIdentifier: model.type.rawValue, for: index)
        if let regCell = cell as? RegistrationTableCell {
            regCell.type = model.type
            regCell.viewModel = self
            regCell.refresh(model)
        }
        return cell
    }
    
    private func cell(for type: MyTableCellType) -> RegistrationTableCell.Type {
        switch type {
        case .pictureShowable:
            return RegistrationTableImageCell.self
        case .inputable:
            return RegistrationTextFieldTableCell.self
        case .selectable:
            return RegistrationSelectableTableCell.self
        case .singleClickable:
            return RegistrationSingleButtonTableCell.self
        }
    }
}
