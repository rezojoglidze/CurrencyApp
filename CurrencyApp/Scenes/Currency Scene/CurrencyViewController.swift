//
//  ViewController.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit
import RxSwift
import RxCocoa

class CurrencyViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var sellCurrencyAmountInputTextField: UITextField!
    @IBOutlet private weak var buyCurrencyAmountLabel: UILabel!
    @IBOutlet private weak var sellButton: UIButton!
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var scrollViewBottomLayout: NSLayoutConstraint!
    
    // MARK: Properties
    private var viewModel: CurrencyViewModel!
    private lazy var pickerView: UIPickerView = UIPickerView()
    private lazy var toolBar = UIToolbar()
    private lazy var disposeBag = DisposeBag()
    
    //MARK: Instantiate
    static func instantiate(viewModel: CurrencyViewModel) -> CurrencyViewController {
        let storyBoard = UIStoryboard(name: "Currency", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as? CurrencyViewController ?? .init()
        viewController.viewModel = viewModel
        return viewController
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setupObservables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: Setup
    private func setupObservables() {
        viewModel.rateDidLoad.subscribe(onNext: { [weak self] rate in
            self?.buyCurrencyAmountLabel.text = rate.amount
            self?.collectionView.reloadData()
            self?.configureSubmitButton(isEnabled: true)
        }).disposed(by: disposeBag)
        
        viewModel.showAlert.subscribe(onNext: { [weak self] text in
            self?.showAlert(text: text)
            self?.configureSubmitButton(isEnabled: true)
        }).disposed(by: disposeBag)
    }
    
    private func setUp() {
        setUpView()
        setUpCollectionView()
        sellCurrencyAmountInputTextField.delegate = self
    }
    
    private func setUpView() {
        dismissKeyboardOnOutsideTap()
        submitButton.setTitle("submit".uppercased(), for: .normal)
        submitButton.layer.cornerRadius = 24
    }
    
    private func setUpPickerView() {
        pickerView.removeFromSuperview()
        toolBar.removeFromSuperview()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        pickerView.setValue(UIColor.black, forKey: "textColor")
        pickerView.autoresizingMask = .flexibleWidth
        pickerView.contentMode = .center
        pickerView.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        view.addSubview(pickerView)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))]
        view.addSubview(toolBar)
    }
    
    @objc func doneButtonTapped() {
        let index = pickerView.selectedRow(inComponent: 0)
        buyCurrencyAmountLabel.text = "---"
        updateCurrencyButtons(index: index)
        toolBar.removeFromSuperview()
        pickerView.removeFromSuperview()
    }
    
    private func setUpCollectionView() {
        collectionView.register(UINib(nibName: String(describing: BalanceCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: BalanceCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureSubmitButton(isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
        submitButton.backgroundColor = isEnabled ? .systemBlue : .darkGray
    }
    
    private func updateCurrencyButtons(index: Int) {
        let currency = viewModel.getSelectedCurrency(row: index)
        let button = viewModel.isSell ? sellButton : buyButton
        button?.setTitle(currency.rawValue.uppercased(), for: .normal)
    }

    //MARK: IBActions
    @IBAction func chooseButtonTappedAtSellView(_ sender: Any) {
        viewModel.isSell = true
        setUpPickerView()
    }
    
    @IBAction func chooseButtonTappedAtBuyView(_ sender: Any) {
        viewModel.isSell = false
        setUpPickerView()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let amount = Decimal(string: sellCurrencyAmountInputTextField.text ?? "") else { return }
        configureSubmitButton(isEnabled: false)
        viewModel.submitButtonTapped(amount: amount)
    }
    
    //MARK: Keyboard
    private func setUpKeyboardObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            self.scrollView.contentSize = CGSize(width: view.frame.width, height: self.scrollView.frame.height)
        } else {
            self.scrollView.contentSize = CGSize(width: view.frame.width, height: self.scrollView.frame.height + keyboardViewEndFrame.height)
        }
        view.layoutIfNeeded()
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: Collection View DataSource and Delegate
extension CurrencyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.collectionViewNumberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BalanceCell.self), for: indexPath) as? BalanceCell
        cell?.fill(text: viewModel.getBalanceInfo(with: indexPath.row))
        return cell ?? UICollectionViewCell()
    }
}

//MARK: Picker View Delegate and DataSource
extension CurrencyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.pickerViewNumberOfRowsInComponent
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.pickerViewTitleForRow(row: row)
    }
}

//MARK: text field Delegate
extension CurrencyViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        if let regex = try? NSRegularExpression(pattern: "^[0-9]*((\\.|,)[0-9]{0,2})?$", options: .caseInsensitive) {
            return regex.numberOfMatches(in: newText, options: .reportProgress, range: NSRange(location: 0, length: (newText as NSString).length)) > 0
        }
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        buyCurrencyAmountLabel.text = "---"
    }
}
