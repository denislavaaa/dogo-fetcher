//
//  ViewController.swift
//  DogoFetcherDemo
//
//  Created by Denislava Shentova on 24.01.23.
//

import UIKit
import DogoFetcher

class ViewController: UIViewController {

    private let dogoFetcher = DogoFetcher()
    
    private let imageView = UIImageView()
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(
                systemName: "arrow.left.circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .black, scale: .large)
            ),
            for: .normal
        )
        button.setTitleColor(.green, for: .normal)
        button.addTarget(self, action: #selector(didPressPrevious), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(
                systemName: "arrow.right.circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .black, scale: .large)
            ),
            for: .normal
        )
        button.setTitleColor(.green, for: .normal)
        button.addTarget(self, action: #selector(didPressNext), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [previousButton, nextButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
     
    private lazy var preloadTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.inputView = picker
        return textField
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(configuration: .borderedProminent())
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(didPressSubmit), for: .touchUpInside)
        return button
    }()
    
    private lazy var textFieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [preloadTextField, submitButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // attach gallery index observer
        Task {
            await dogoFetcher.setGalleryIndexObserver { [weak self] index in
                Task { @MainActor in
                    self?.previousButton.isEnabled = index > 0
                }
            }
        }
        // get first image
        Task {
            let image = try? await dogoFetcher.getNextImage()
            imageView.image = image
        }
        
    }
    
    private func setupUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        textFieldStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textFieldStack)
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: textFieldStack.topAnchor),
        ])

        NSLayoutConstraint.activate([
            textFieldStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldStack.bottomAnchor.constraint(equalTo: buttonStack.topAnchor),
            textFieldStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc private func didPressNext() {
        Task { [weak self] in
            do {
                if let image = try await self?.dogoFetcher.getNextImage() {
                    imageView.image = image
                }
            } catch {
                print(error)
            }
            
        }
    }
    
    @objc private func didPressPrevious() {
        Task { [weak self] in
            do {
                if let image = try await self?.dogoFetcher.getPreviousImage() {
                    imageView.image = image
                }
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func didPressSubmit() {
        guard let imageCount = Int(preloadTextField.text ?? "") else {
            return
        }
        Task {
            let images = try? await dogoFetcher.getImages(count: imageCount)
            print("Preloaded \(images?.count ?? 0) images")
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        10
    }
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(row+1)"
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        preloadTextField.text = "\(row+1)"
        view.endEditing(true)
    }
    
}

