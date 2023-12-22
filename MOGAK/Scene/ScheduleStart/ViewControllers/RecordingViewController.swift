//
//  RecodingViewController.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/15.
//

import UIKit
import SnapKit
import Then
import PhotosUI

protocol RecordingVCdelegate {
    func moveRecordingVC()
}

class RecordingViewController : UIViewController, UIScrollViewDelegate,PHPickerViewControllerDelegate{
    
    //MARK: - Properties
    
    private lazy var popButton : UIButton = {
        let popButton = UIButton()
        popButton.backgroundColor = .clear //백그라운드색
        popButton.setImage(UIImage(named: "backButton_black"), for: .normal)
        popButton.addTarget(self, action: #selector(backhome), for: .touchUpInside)
        return popButton
    }()
    
    private lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "조각 내용 기록"
        titleLabel.textColor = UIColor(hex: "24252E")
        titleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        return titleLabel
    }()
    
    //MARK: - ScrollView
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    //MARK: - contentView
    private lazy var contentView : UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
    
    private lazy var categoryLabel : UILabel = {
        let label = UILabel()
        label.text = "직무"
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.backgroundColor = UIColor(red: 0.867, green: 0.968, blue: 1, alpha: 1)
        label.textColor = UIColor(red: 0, green: 0.671, blue: 0.883, alpha: 1)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    
    private lazy var mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "자격증 4개 따기"
        label.font = UIFont(name: "PretendardVariable-SemiBold", size: 16)
        return label
    }()
    
    private lazy var jogakView : UIView = {
        let cellView = UIView()
        cellView.layer.cornerRadius = 10
        cellView.layer.shadowColor = UIColor(red: 0.749, green: 0.765, blue: 0.831, alpha: 0.5).cgColor
        cellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cellView.layer.shadowOpacity = 1
        cellView.layer.shadowRadius = 10
        cellView.backgroundColor = .white
        return cellView
    }()
    
    let jogakViewImage : UIImageView = {
        let cellViewImage = UIImageView()
        cellViewImage.backgroundColor = .clear
        cellViewImage.image = UIImage(named: "squareCheckmark")
        return cellViewImage
    }()
    
    var jogakLabel : UILabel = {
        let cellLabel = UILabel()
        cellLabel.text = "기획 아티클 읽기"
        cellLabel.textColor = UIColor(red: 0.142, green: 0.147, blue: 0.179, alpha: 1)
        cellLabel.font = UIFont(name: "PretendardVariable-Medium", size: 16)
        return cellLabel
    }()
    
    //MARK: - TextView
    
    private let textViewLabel : UILabel = {
        let textViewLabel = UILabel()
        textViewLabel.text = "글을 작성해주세요"
        textViewLabel.font = UIFont(name: "PretendardVariable-Medium", size: 16)
        textViewLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        return textViewLabel
    }()
    
    private lazy var textbackgroundView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor(red: 0.947, green: 0.953, blue: 0.979, alpha: 1)
        return view
    }()
    
    private lazy var textView : UITextView = {
        let textView = UITextView()
        textView.text = "오늘 당신의 조각은 어떠셨나요?\n느낀 점이나 기억에 남는 것을 공유해보세요"
        textView.textColor = UIColor(red: 0.5, green: 0.518, blue: 0.592, alpha: 1)
        textView.backgroundColor = .clear
        return textView
    }()
    
    private var selections = [String : PHPickerResult]()
    private var imagesDict = [String: UIImage]()
    
    private var selectedAssetIdentifiers = [String]()
    
    let galleryCell = GalleryCollectionViewCell()
    let schduleVC = ScheduleStartViewController()
    
    
    //MARK: - galleryCollectioview
    private lazy var galleryCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // 가로 스크롤 활성화
        
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200), collectionViewLayout: layout)
        view.isScrollEnabled = true
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var galleryStackView : UIStackView = {
        let stackview  = UIStackView()
        stackview.spacing = 12
        stackview.axis = .horizontal
        stackview.backgroundColor = .clear
        return stackview
    }()
    
    private lazy var finishButton : UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.backgroundColor = UIColor(red: 0.749, green: 0.766, blue: 0.833, alpha: 1)
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        self.scrollView.delegate = self
        self.textView.delegate = self
        setCollectionView()
        setUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
             self.view.endEditing(true)
       }
    
    
    func setUI(){
        [popButton,titleLabel].forEach{view.addSubview($0)}
        
        contentView.addSubviews(categoryLabel,mogakLabel,textbackgroundView,textView,jogakView,jogakViewImage,jogakLabel,textViewLabel,galleryStackView,galleryCollectionView,finishButton)
        
        popButton.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(popButton)
        }
        
        scrollView.snp.makeConstraints{
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            
        }
        
        contentView.snp.makeConstraints{
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.height.greaterThanOrEqualTo(scrollView.snp.height).priority(.low)
            $0.width.equalTo(scrollView.snp.width)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(finishButton.snp.bottom).offset(20)
            
        }
        categoryLabel.snp.makeConstraints{
            $0.width.equalTo(49)
            $0.height.equalTo(26)
            $0.top.equalToSuperview().inset(30)
            $0.leading.equalTo(contentView).inset(20)
            
        }
        mogakLabel.snp.makeConstraints{
            $0.top.equalTo(categoryLabel.snp.bottom).offset(10)
            $0.leading.equalTo(jogakView)
            
        }
        
        
        jogakView.snp.makeConstraints{
            $0.leading.trailing.equalTo(contentView).inset(20)
            $0.top.equalTo(mogakLabel.snp.bottom).offset(10)
            $0.height.equalTo(70)
        }
        
        jogakViewImage.snp.makeConstraints{
            $0.centerY.equalTo(jogakView)
            $0.leading.equalTo(jogakView.snp.leading).offset(16)
        }
        
        textViewLabel.snp.makeConstraints{
            $0.top.equalTo(jogakView.snp.bottom).offset(32)
            $0.leading.equalTo(contentView).inset(25)
        }
        
        textbackgroundView.snp.makeConstraints{
            $0.leading.trailing.equalTo(contentView).inset(20)
            $0.top.equalTo(textViewLabel.snp.bottom).offset(12)
            $0.bottom.equalTo(textView.snp.bottom).offset(16)
            $0.height.equalTo(411)
            
        }
        
        jogakLabel.snp.makeConstraints{
            $0.centerY.equalTo(jogakViewImage)
            $0.leading.equalTo(jogakViewImage.snp.trailing).offset(12)
        }
        
        
        textView.snp.makeConstraints{ //수정요망
            $0.top.equalTo(textbackgroundView.snp.top).offset(16)
            $0.leading.trailing.bottom.equalTo(textbackgroundView).inset(16)
        }
        
        galleryCollectionView.snp.makeConstraints{
            $0.top.equalTo(textbackgroundView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
        galleryStackView.snp.makeConstraints{
            $0.top.equalTo(textbackgroundView.snp.bottom).offset(28)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(72)
            
        }
        
        finishButton.snp.makeConstraints{
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(galleryCollectionView)
            $0.height.equalTo(52)
        }
        
    }
    
    func setCollectionView(){
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: "GalleryCollectionViewCell")
    }
    
    //MARK: - Gallery Setting
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        var newSelections = [String: PHPickerResult]()
        
        for result in results {
            let identifier = result.assetIdentifier!
            newSelections[identifier] = selections[identifier] ?? result
            
            
        }
        
        selections = newSelections
        selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
        
        if selections.isEmpty {
            galleryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            print("empty")
            
        } else {
            displayImage()
            //사진이 있을때 .clear
            for index in 0..<min(4, self.selectedAssetIdentifiers.count) {
                if index < self.selectedAssetIdentifiers.count,
                   let cell = self.galleryCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? GalleryCollectionViewCell {
                    
                    cell.grayView.backgroundColor = .clear
                    cell.plusView.tintColor = .clear
                }
            }
        }
    }
    
    private func displayImage() {
        let dispatchGroup = DispatchGroup()
        // identifier와 이미지로 dictionary를 만듬 (selectedAssetIdentifiers의 순서에 따라 이미지를 받을 예정입니다.)
        var imagesDict = [String: UIImage]()
        
        for (identifier, result) in selections {
            
            dispatchGroup.enter()
            
            let itemProvider = result.itemProvider
            // 만약 itemProvider에서 UIImage로 로드가 가능하다면?
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                // 로드 핸들러를 통해 UIImage를 처리해 줍시다. (비동기적으로 동작)
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image as? UIImage else { return }
                    imagesDict[identifier] = image
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            
            // 먼저 스택뷰의 서브뷰들을 모두 제거함
            self.galleryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // 선택한 이미지의 순서대로 정렬하여 스택뷰에 올리기
            for identifier in self.selectedAssetIdentifiers {
                guard let image = imagesDict[identifier] else { return }
                self.addImage(image)
                
            }
        }
        
    }
    
    private func addImage(_ image: UIImage) {
        let myimageView = UIImageView()
        myimageView.image = image
        myimageView.layer.cornerRadius = 14
        myimageView.layer.masksToBounds = true
        myimageView.backgroundColor = .clear
        
        myimageView.snp.makeConstraints {
            $0.width.height.equalTo(72)
        }
        
        galleryStackView.addArrangedSubview(myimageView)
        
    }
    
    
    //MARK: - @objc func
    @objc func backhome(){
        self.dismiss(animated: true)
        print("back home")
    }
    
    @objc func clickbutton(){
        
        if let text = textView.text{
            NotificationCenter.default.post(name: NSNotification.Name( "RecordText"), object: text)
        }
        self.dismiss(animated: true)
        print(textView.text!)
        schduleVC.ScheduleTableView.reloadData()
    }
    
    
}

//MARK: - exteinson CollectioView
extension RecordingViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    //cell 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    //cell 재사용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as? GalleryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    //Cell의 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.height , height: collectionView.frame.height)
    }
    
    //cell의 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    //MARK: - 클릭시 갤러리 열림
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.section), \(indexPath.row)")
        cellClicked()
    }
    
    
    public func cellClicked(){
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.any(of: [.images])
        configuration.selectionLimit = 4
        configuration.selection = .ordered
        configuration.preferredAssetRepresentationMode = .current
        configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        self.present(picker, animated: true, completion: nil)
    }
}



extension RecordingViewController : UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == UIColor(red: 0.5, green: 0.518, blue: 0.592, alpha: 1) else {return}
        textView.text = nil
        textView.textColor = .label
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "오늘 당신의 조각은 어떠셨나요?\n느낀 점이나 기억에 남는 것을 공유해보세요"
            textView.textColor = UIColor(red: 0.5, green: 0.518, blue: 0.592, alpha: 1)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in : currentText) else {return false}
        
        let changeText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if changeText.count > 0{
            finishButton.backgroundColor = DesignSystemColor.signature.value
            finishButton.addTarget(self, action: #selector(clickbutton), for: .touchUpInside)
            
        }else{
            finishButton.backgroundColor = UIColor(red: 0.749, green: 0.766, blue: 0.833, alpha: 1)
            
        }
        
        return changeText.count > 0
    }
}









//Preview code
#if DEBUG
import SwiftUI
struct RecordingViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        RecordingViewController()
    }
}
@available(iOS 13.0, *)
struct RecordingViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(iOS 14.0, *) {
                RecordingViewControllerRepresentable()
                    .ignoresSafeArea()
                    .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                    .previewDevice(PreviewDevice(rawValue: "iPhone se"))
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
} #endif



