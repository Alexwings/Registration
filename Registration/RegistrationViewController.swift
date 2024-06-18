//
//  ViewController.swift
//  Registration
//
//  Created by Xinyuan_Wang on 2023/8/20.
//

import UIKit
import PhotosUI

class RegistrationViewController: UIViewController {
    
    private var tableViewModel: RegistrationTableViewModel?
    
    private var imagePickingCompletion: ((UIImage) -> Void)?
    
    private var colorPickerCompletion: ((UIColor?) -> Void)?
    
    lazy var table: UITableView = {
        let t = UITableView(frame: self.view.bounds, style: .plain)
        t.delegate = self
        t.translatesAutoresizingMaskIntoConstraints = false
        t.separatorStyle = .none
        t.tableFooterView = UIView()
        t.allowsSelection = false
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Registration"
        let data =  [
            MyTableModel(type: .pictureShowable, title: "Avatar", hint: ""),
            MyTableModel(type: .inputable, title: "First Name", hint: "Please input"),
            MyTableModel(type: .inputable, title: "Last Name", hint: "Please input"),
            MyTableModel(type: .inputable, title: "Phone Number", hint: "Please input"),
            MyTableModel(type: .inputable, title: "Email", hint: "Please input"),
            MyTableModel(type: .selectable, title: "Custom Avatar Color", hint: "Please select"),
            MyTableModel(type: .singleClickable, title: "", hint: "Sign Up")
        ]
        self.view.addSubview(table)
        table.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        table.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        table.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableViewModel = RegistrationTableViewModel(with: table)
        tableViewModel?.controller = self
        tableViewModel?.loadAll(data)
    }
    
    func presentImagePicker(completion: @escaping ((UIImage) -> Void)) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        let picker = PHPickerViewController(configuration: config)
        self.imagePickingCompletion = completion
        picker.delegate = self
        self .present(picker, animated: true)
    }
    
    func presentColorPicker(fromSource view: UIView?, completion: @escaping ((UIColor?) -> Void)) {
        let title = "Image Background Color"
        let colorPicker = UIColorPickerViewController()
        colorPicker.title = title
        colorPicker.supportsAlpha = false
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        colorPicker.popoverPresentationController?.sourceView = view
        self.colorPickerCompletion = completion
        self.present(colorPicker, animated: true)
    }
}

extension RegistrationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewModel?.height(for: indexPath) ?? 0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewModel?.height(for: indexPath) ?? 0
    }
}

extension RegistrationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if picker.configuration.selectionLimit == 1, let result = results.first {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.imagePickingCompletion?(image)
                    }
                }
            }
        }
    }
}

extension RegistrationViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        if continuously {
            return
        }
        DispatchQueue.main.async {
            self.colorPickerCompletion?(color)
        }
    }
}
