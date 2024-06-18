//
//  RegistrationTableCell.swift
//  Registration
//
//  Created by Xinyuan_Wang on 2023/8/20.
//

import UIKit

class RegistrationTableCell: UITableViewCell {
    
    var type: MyTableCellType?
    weak var viewModel: RegistrationTableViewModel?
    
    var titleLabel: UILabel? = UILabel()
    var containerView: UIView = UIView()
    var rightContainer: UIView = UIView()
    
    private var titlelabelWidth: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    convenience init(type: MyTableCellType, viewModel: RegistrationTableViewModel?) {
        self.init(style: .default, reuseIdentifier: type.rawValue)
        self.type = type
        self.viewModel = viewModel
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupViews()  {
        containerView.removeFromSuperview()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 5.0
        containerView.layer.borderWidth = 2.0
        containerView.layer.borderColor = UIColor.black.cgColor
        contentView.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        titleLabel?.removeFromSuperview()
        rightContainer.removeFromSuperview()
        titleLabel = UILabel()
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.text = "Title"
        rightContainer = UIView()
        rightContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel!)
        containerView.addSubview(rightContainer)
        titleLabel?.sizeToFit()
        titleLabel?.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15).isActive = true
        titleLabel?.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        titleLabel?.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        titlelabelWidth = titleLabel?.widthAnchor.constraint(equalToConstant: titleLabel?.frame.width ?? 0)
        titlelabelWidth?.isActive = true
        rightContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15).isActive = true
        let top = rightContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant:5 )
        let bottom = rightContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
        top.isActive = true
        bottom.isActive = true
        rightContainer.leadingAnchor.constraint(equalTo: titleLabel!.trailingAnchor).isActive = true
    }
    
    func refresh(_ model: MyTableModel) {
        self.type = model.type
        self.titleLabel?.text = model.title
        self.titleLabel?.sizeToFit()
        titlelabelWidth?.constant = titleLabel?.frame.width ?? 0
        configRightView(for: model)
    }
    fileprivate func configRightView(for model: MyTableModel) {}
}

class RegistrationTableImageCell: RegistrationTableCell {
    private var image: ColorBackedImageView?
    
    override func configRightView(for model: MyTableModel) {
        let image = self.image ?? ColorBackedImageView(frame: .zero)
        DispatchQueue.main.async {
            if let detail = model.detail as? MyDetailModel {
                image.image = detail.image ?? UIImage(named: "default_avatar")
                image.backgroundColor = detail.color ?? .white
            }else {
                image.image = UIImage(named: "default_avatar")
            }
        }
        if image.superview == nil {
            image.translatesAutoresizingMaskIntoConstraints = false
            rightContainer.addSubview(image)
            image.topAnchor.constraint(equalTo: rightContainer.topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor).isActive = true
            image.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor).isActive = true
            image.widthAnchor.constraint(equalTo: image.heightAnchor).isActive = true
            let gesture = UITapGestureRecognizer()
            gesture.numberOfTapsRequired = 1
            gesture.addTarget(self, action: #selector(imageTapped))
            image.addGestureRecognizer(gesture)
            
        }
        self.image = image
        rightContainer.setNeedsDisplay()
    }
    
    @objc func imageTapped() {
        self.viewModel?.event(for: self)
    }
}

class RegistrationTextFieldTableCell: RegistrationTableCell, UITextFieldDelegate {
    var textField: UITextField?
    override func configRightView(for model: MyTableModel) {
        let textField = UITextField()
        textField.delegate = self
        if let text = model.detail as? String, !text.isEmpty {
            textField.text = text
        } else {
            textField.placeholder = model.hint
        }
        textField.textAlignment = .right
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.rightContainer.addSubview(textField)
        textField.topAnchor.constraint(equalTo: rightContainer.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor).isActive = true
        self.textField = textField
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.viewModel?.event(for: self)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.isHighlighted {
            textField.resignFirstResponder()
        }
        return true
    }
}

class RegistrationSelectableTableCell: RegistrationTableCell {
    var button: UIButton?
    override func configRightView(for model: MyTableModel) {
        if self.button == nil {
            let button = self.button ?? UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(.lightGray, for: .normal)
            button.setTitleColor(.blue, for: .highlighted)
            button.setTitle(model.hint, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.contentHorizontalAlignment = .trailing
            rightContainer.addSubview(button)
            button.topAnchor.constraint(equalTo: rightContainer.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor).isActive = true
            button.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor).isActive = true
            button.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor).isActive = true
            button .addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            self.button = button
        }
        if let value = model.detail as? String, !value.isEmpty {
            self.button?.setTitle(value, for: .normal)
        }
        
    }
    
    @objc func buttonClicked() {
        self.viewModel?.event(for: self)
    }
}

class RegistrationSingleButtonTableCell: RegistrationTableCell {
    override func configRightView(for model: MyTableModel) {
        let button = UIButton(type: .custom)
        button.setTitle(model.hint, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        rightContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: rightContainer.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: rightContainer.centerYAnchor),
            button.heightAnchor.constraint(equalTo: rightContainer.heightAnchor, constant: -10),
            button.widthAnchor.constraint(equalTo: rightContainer.widthAnchor, constant: -10)
        ])
        button .addTarget(self, action: #selector(buttonCliced), for: .touchUpInside)
    }
    
    @objc func buttonCliced() {
        self.viewModel?.event(for: self)
    }
}
