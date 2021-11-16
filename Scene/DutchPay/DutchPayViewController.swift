//
//  DutchPayViewController.swift
//  tosshomeworkSample
//
//  Created by chiman song on 2021/11/15.
//  Copyright © 2021 Viva Republica. All rights reserved.
//

import Foundation
import UIKit
//import RxSwift
//import RxDataSources

final class DutchPayViewController: UIViewController {
    
    private enum CellId {
        static let cell = "cell"
        static let header = "header"
    }
    
    // MARK: UI Compoenent
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: self.view.frame,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(
            DutchPayCollectionViewCell.self,
            forCellWithReuseIdentifier: CellId.cell
        )
        collectionView.register(
            DutchPayCollectionViewHeaderCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CellId.header
        )
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    //MARK: Property
    private let viewModel: DutchPayViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        self.addSubviews()
        self.layoutComponents()
        self.bindViewModel()
    }
    
    init(viewModel: DutchPayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        self.viewModel.dutchPayData.bind { [weak self] data in
            guard let `self` = self else { return }
            self.collectionView.reloadData()
        }
    }
    
    private func addSubviews() {
        [self.collectionView].forEach {
            self.view.addSubview($0)
        }
    }
    
    private func layoutComponents() {
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func animateProgressButton() {
        if let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? DutchPayCollectionViewCell {
            let data = self.viewModel.dutchPayData.value?.dutchDetailList?[0]
            if data?.paymentStatus == .sendingRequest {
                cell.progressAnimationButton.animate(from: 0)
            }
        }
    }
}

extension DutchPayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width, height: 72)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        if let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? DutchPayCollectionViewHeaderCell {

            let height = headerView.contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height

            return CGSize(width: self.view.frame.width, height: height)

        } else {
            return CGSize(width: 0, height: 0)
        }

        
    }
}

extension DutchPayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.dutchPayData.value?.dutchDetailList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.cell, for: indexPath) as? DutchPayCollectionViewCell {
            let data: DutchPayData.DutchDetail? = self.viewModel.dutchPayData.value?.dutchDetailList?[indexPath.item]
            
            cell.configure(data: data)
            
            cell.requestPaymentButtonTapHandler = { [weak self] status in
                guard let `self` = self else { return }
                self.viewModel.updatePaymentStatus(index: indexPath.item)
            }
            
            return cell
        } else {
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellId.header, for: indexPath) as? DutchPayCollectionViewHeaderCell {
                let data = self.viewModel.dutchPayData.value?.dutchSummary
                cell.configure(data: data)
                return cell
            } else {
                fatalError()
            }
        default:
            fatalError()
        }
    }
}

