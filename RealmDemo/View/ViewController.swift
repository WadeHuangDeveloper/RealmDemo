//
//  ViewController.swift
//  RealmDemo
//
//  Created by Huei-Der Huang on 2025/3/19.
//

import UIKit
import Combine

class ViewController: UIViewController {
    var viewModel = ViewControllerViewModel()
    private var firstNameTextField = UITextField()
    private var lastNameTextField = UITextField()
    private var emailTextField = UITextField()
    private var updateButton = UIButton()
    private var deleteButton = UIButton()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCombine()
        viewModel.read()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cancellables.removeAll()
    }
    
    private func initUI() {
        firstNameTextField.placeholder = TextFieldModel.Title.FirstName
        firstNameTextField.delegate = self
        firstNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: firstNameTextField.frame.height))
        firstNameTextField.leftViewMode = .always
        firstNameTextField.layer.borderWidth = 1
        firstNameTextField.layer.borderColor = TextFieldColor.default.cgColor
        firstNameTextField.layer.cornerRadius = 5
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        lastNameTextField.placeholder = TextFieldModel.Title.LastName
        lastNameTextField.delegate = self
        lastNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: firstNameTextField.frame.height))
        lastNameTextField.leftViewMode = .always
        lastNameTextField.layer.borderWidth = 1
        lastNameTextField.layer.borderColor = TextFieldColor.default.cgColor
        lastNameTextField.layer.cornerRadius = 5
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        emailTextField.placeholder = TextFieldModel.Title.Email
        emailTextField.delegate = self
        emailTextField.autocapitalizationType = .none
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: firstNameTextField.frame.height))
        emailTextField.leftViewMode = .always
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = TextFieldColor.default.cgColor
        emailTextField.layer.cornerRadius = 5
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        updateButton.addTarget(self, action: #selector(onUpdateButtonClick), for: .touchUpInside)
        updateButton.setTitle(TextFieldModel.Title.Save, for: .normal)
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.backgroundColor = .link
        updateButton.layer.cornerRadius = 5
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.addTarget(self, action: #selector(onDeleteButtonClick), for: .touchUpInside)
        deleteButton.setTitle(TextFieldModel.Title.Delete, for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.layer.cornerRadius = 5
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .systemBackground
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        view.addSubview(emailTextField)
        view.addSubview(updateButton)
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            firstNameTextField.heightAnchor.constraint(equalToConstant: 50),
            firstNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            firstNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            lastNameTextField.heightAnchor.constraint(equalToConstant: 50),
            lastNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            lastNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 20),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            updateButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            updateButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            deleteButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 20),
        ])
    }
    
    private func setupCombine() {
        viewModel.userSubject
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.showAlert(error: error)
                default:
                    break
                }
            } receiveValue: { user in
                self.updateUserData(user: user)
            }.store(in: &cancellables)
        
        viewModel.statusObject
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.showAlert(error: error)
                default:
                    break
                }
            } receiveValue: { status in
                switch status {
                case .create, .update:
                    self.showAlert(message: Alert.SaveSuccess)
                case .delete:
                    self.showAlert(message: Alert.DeleteSuccess)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor @objc private func onUpdateButtonClick() {
        view.endEditing(true)
        
        let textFields: [(UITextField, String)] = [
            (firstNameTextField, TextFieldModel.Title.FirstName),
            (lastNameTextField, TextFieldModel.Title.LastName),
            (emailTextField, TextFieldModel.Title.Email),
        ]
        
        var invalidErrorMessages: [String] = []
        for (textField, errorMessage) in textFields {
            if let text = textField.text, !text.isEmpty {
                textField.layer.borderColor = TextFieldColor.default.cgColor
            } else {
                textField.layer.borderColor = TextFieldColor.error.cgColor
                invalidErrorMessages.append(errorMessage)
            }
        }
        
        guard invalidErrorMessages.isEmpty else {
            showAlert(message: "Please enter:\n" + invalidErrorMessages.joined(separator: "\n"))
            return
        }
        
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        viewModel.createOrUpdate(firstName: firstName, lastName: lastName, email: email)
    }
    
    @MainActor @objc private func onDeleteButtonClick() {
        view.endEditing(true)
        
        if viewModel.userSubject.value != nil {
            viewModel.delete()
        }
    }

    @MainActor @objc private func onTapGesture() {
        view.endEditing(true)
    }
    
    @MainActor private func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    @MainActor private func showAlert(error: RealmServiceError) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    @MainActor private func updateUserData(user: UserObject?) {
        firstNameTextField.text = user?.firstName
        lastNameTextField.text = user?.lastName
        emailTextField.text = user?.email
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = TextFieldColor.default.cgColor
        return true
    }
}
