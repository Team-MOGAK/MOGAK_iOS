//
//  MG2ModalartTitleEditorModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/19.
//

import UIKit
import SnapKit

final class MG2ModalartTitleEditorModal: UIViewController {
    private let viewModel: MG2ModalartTitleEditorViewModel
    var onCancel: (() -> Void)?
    var onSubmit: ((String, String) -> Void)?

    private let headerView = MG2SheetHeaderView(title: "최종 목표")
    private let titleLabel = MG2FieldLabel("나의 최종 목표는?")

    private let titleSetTextField: MG2TextField = {
        let textField = MG2TextField()
        textField.placeholder = "이루고 싶은 최종 목표를 적어 주세요"
        textField.autocorrectionType = .no
        textField.accessibilityLabel = "최종 목표"
        return textField
    }()

    private let hintLabel: MG2HintLabel = {
        let label = MG2HintLabel()
        label.show("최대 20자까지 적을 수 있어요")
        return label
    }()

    private let colorLabel = MG2FieldLabel("판 색")

    private let completeButton: MG2PrimaryActionButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("최종 목표 저장", for: .normal)
        return button
    }()

    // MARK: - 컬러 차트
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: DS.Size.touch, height: DS.Size.touch)
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: DS.Space.sheet)
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    init(viewModel: MG2ModalartTitleEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
        configureCollectionView()
        titleSetTextField.text = viewModel.state.title
        if let selectedColorIndex = viewModel.selectedColorIndex {
            colorCollectionView.selectItem(at: IndexPath(item: selectedColorIndex, section: 0), animated: false, scrollPosition: [])
        }
        renderSubmitState()
    }

    // MARK: - 뷰컨 셋팅(textField에 텍스트 넣어주기, addTarget달아주기)
    private func configureView() {
        view.backgroundColor = DS.Color.surface
        headerView.onClose = { [weak self] in self?.onCancel?() }

        titleSetTextField.delegate = self
        titleSetTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    // MARK: - 터치됐을 때 설정
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - 완료버튼 눌렀을 때
    @objc private func completeButtonTapped() {
        guard let submission = viewModel.submission() else { return }
        onSubmit?(submission.title, submission.color)
    }

    // MARK: - textField가 변경되고 난 후
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.updateTitle(textField.text ?? "")
        renderSubmitState()
    }

    // MARK: - 컬러 차트 collectionView 셋팅
    private func configureCollectionView() {
        colorCollectionView.register(MG2ColorSelectionCell.self, forCellWithReuseIdentifier: MG2ColorSelectionCell.identifier)

        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }

    // MARK: - 완료 버튼 backgroundColor & isEnabled변경
    private func renderSubmitState() {
        completeButton.isEnabled = viewModel.state.canSubmit
    }
}

extension MG2ModalartTitleEditorModal {
    // MARK: - 뷰들 레이아웃 잡기
    private func configureLayout() {
        view.addSubviews(headerView, titleLabel, titleSetTextField, hintLabel, colorLabel, colorCollectionView, completeButton)

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        titleSetTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        hintLabel.snp.makeConstraints {
            $0.top.equalTo(titleSetTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        colorLabel.snp.makeConstraints {
            $0.top.equalTo(hintLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        colorCollectionView.snp.makeConstraints {
            $0.top.equalTo(colorLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(DS.Space.sheet)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(DS.Size.touch)
        }
        completeButton.snp.makeConstraints {
            $0.top.equalTo(colorCollectionView.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.equalTo(DS.Size.button)
            $0.bottom.lessThanOrEqualToSuperview().inset(DS.Space.sheet)
        }
    }
}

extension MG2ModalartTitleEditorModal: UITextFieldDelegate {
    // MARK: - 텍스트필드 글자수 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }

        guard let stringLength = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringLength, with: string)
        return viewModel.canUpdateTitle(updatedText)
    }

    // MARK: - return키 눌렀을때 키보드 내려가도록 설정
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

extension MG2ModalartTitleEditorModal: UICollectionViewDataSource{
    // MARK: - 한 섹션안에 컬러 차트의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.colors.count
    }

    // MARK: - cell 셋팅
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: MG2ColorSelectionCell.identifier, for: indexPath)
        guard let cell = reusableCell as? MG2ColorSelectionCell else { return reusableCell }
        cell.configure(serverHex: viewModel.colors[indexPath.row], accessibilityName: "판 색 \(indexPath.row + 1)")
        return cell
    }
}

extension MG2ModalartTitleEditorModal: UICollectionViewDelegate {
    // MARK: - 컬러가 선택되었을 때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectColor(at: indexPath.row)
        renderSubmitState()
    }
}
