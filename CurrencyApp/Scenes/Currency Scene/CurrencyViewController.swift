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
    
    // MARK: Setup
    private func setupObservables() {
        viewModel.rateDidLoad.subscribe(onNext: { [weak self] rate in
            print(rate, "dasdada")
        }).disposed(by: disposeBag)
        
        viewModel.showAlert.subscribe(onNext: { [weak self] text in
            self?.showAlert(text: text)
        }).disposed(by: disposeBag)
    }
    
    private func setUp() {
        setUpView()
        setUpCollectionView()
    }
    
    private func setUpView() {
        dismissKeyboardOnOutsideTap()
        submitButton.setTitle("submit".uppercased(), for: .normal)
        submitButton.layer.cornerRadius = 24
    }
    
    private func setUpPickerView() {
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
        toolBar.removeFromSuperview()
        pickerView.removeFromSuperview()
    }
    
    private func setUpCollectionView() {
        collectionView.register(UINib(nibName: String(describing: BalanceCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: BalanceCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    //MARK: IBActions
    @IBAction func chooseButtonTappedAtSellView(_ sender: Any) {
        setUpPickerView()
    }
    
    @IBAction func chooseButtonTappedAtBuyView(_ sender: Any) {
        setUpPickerView()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        viewModel.submitButtonTapped(amount: Decimal(20))
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
