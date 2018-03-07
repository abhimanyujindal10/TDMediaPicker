//
//  TDMediaPreviewMainView.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 28/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import UIKit

protocol TDMediaPreviewMainViewDataSource: class {
    func previewMainViewHideCaptionView(_ view: TDMediaPreviewMainView)-> Bool?
}

protocol TDMediaPreviewMainViewDelegate: class {
    func previewMainView(_ view: TDMediaPreviewMainView, didDisplayViewAtIndex index: Int)
    func previewMainView(_ view: TDMediaPreviewMainView, didRequestUpdateMedia media: TDPreviewViewModel)
}

class TDMediaPreviewMainView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    // MARK: - Variable(s)
    
    weak var delegate: TDMediaPreviewMainViewDelegate?
    weak var dataSource: TDMediaPreviewMainViewDataSource?
    
    var bottomSpace:CGFloat = 65
    var captionCount:Int = 1000
    
    fileprivate var mediaItems: [TDPreviewViewModel] = []
    fileprivate var selectedIndex: Int = 0
    
    private let rows: CGFloat = 1
    private let cellSpacing: CGFloat = 2
    
    // This logic is used to avoid multiple reload of thumpreview
    private var isScrolledByUser: Bool = true
    private var timer: Timer?
    
    private var currentVisibleIndex = -1
    private var currentPlayerSetupIndex = -1
    
    fileprivate var videoPlayerView: TDMediaVideoView?
    
    @IBOutlet var collectionView:  UICollectionView!
    @IBOutlet var captionTextViewBottomConstraint:NSLayoutConstraint!
    @IBOutlet var captionTextViewHeightConstraint:NSLayoutConstraint!
    @IBOutlet var captionTextView:UITextView!
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        captionTextView.delegate = self
    }
    
    override func layoutSubviews() {
        collectionView.reloadData()
        videoPlayerView?.frame = self.bounds
    }
    
    // MARK: - Public Method(s)
    func getMedia()->[TDPreviewViewModel]{
        return self.mediaItems
    }
    
    func viewWillTransition(){
        isScrolledByUser = false
    }
    
    func viewDidTransition(){
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        isScrolledByUser = true
        self.updateTextViewFrame()
    }
    
    func setupView(){
        TDMediaCell.registerCellWithType(.Image, collectionView: collectionView)
        TDMediaCell.registerCellWithType(.Video, collectionView: collectionView)
        
        videoPlayerView = TDMediaVideoView(frame: self.bounds)
        videoPlayerView?.delegate = self
    }
    
    func purgeData(){
        mediaItems.removeAll()
        videoPlayerView?.removeFromSuperview()
        videoPlayerView = nil
    }
    
    func reload(media: TDMediaPreviewViewModel){
        if  media.previewMedia.count == 0 {
            return
        }
        mediaItems.removeAll()
        mediaItems = media.previewMedia
        
        collectionView.reloadData()
        
        currentVisibleIndex = 0
        selectedIndex = 0
        
        captionTextView.text = mediaItems[selectedIndex].caption
        self.updateTextViewFrame()
        DispatchQueue.main.async {
            self.setupVideoPlayerView()
        }
    }
    
    
    func reload(toIndex: Int){
        
        var shouldScrollAnimated = true
        if abs(selectedIndex - toIndex) > 3{
            shouldScrollAnimated = false
        }
        
        selectedIndex = toIndex
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        
        isScrolledByUser = false
        
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: shouldScrollAnimated)
        
        if !shouldScrollAnimated{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.setupVideoPlayerView()
            })
        }
        
        //TEMP HACK TO AVOID MULTIPLE RELOAD OF THUMB PREVIEW VIEW.
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            self.isScrolledByUser = true
        })
        captionTextView.text = mediaItems[selectedIndex].caption
        self.updateTextViewFrame()
    }
    
    // MARK: - Private Method(s)
    
    private func notifyScrolling(){
        if !isScrolledByUser{
            return
        }
        self.delegate?.previewMainView(self, didDisplayViewAtIndex: currentVisibleIndex)
        selectedIndex = currentVisibleIndex
        captionTextView.text = mediaItems[selectedIndex].caption
        self.updateTextViewFrame()
    }
    
    fileprivate func purgeVideoPlayer(_ completion: @escaping () -> Void){
        videoPlayerView?.removeFromSuperview()
        videoPlayerView?.purgeVideoPlayer {
            completion()
        }
    }
    
    fileprivate func updateTextViewFrame(){
        let contentSize = self.captionTextView.sizeThatFits(self.captionTextView.bounds.size)
        if contentSize.height > 60{
            captionTextViewHeightConstraint.constant = 60
            captionTextView.isScrollEnabled = true
        }else{
            captionTextViewHeightConstraint.constant = contentSize.height
            captionTextView.isScrollEnabled = false
        }
        captionTextView.contentInset = .zero
    }
    
    private func setupVideoPlayerView(){
        if currentVisibleIndex == -1 || (currentPlayerSetupIndex != -1 && currentPlayerSetupIndex == currentVisibleIndex){
            // Stop Setup of player
            videoPlayerView?.stopVideo()
            return
        }
        if mediaItems.count <= currentVisibleIndex{
            return
        }
        let media = mediaItems[currentVisibleIndex]
        if media.asset?.mediaType == .video{
            let cell = collectionView.cellForItem(at: IndexPath(item: currentVisibleIndex, section: 0))
            if cell != nil{
                currentPlayerSetupIndex = currentVisibleIndex
                purgeVideoPlayer {
                    cell?.addSubview(self.videoPlayerView!)
                    self.videoPlayerView?.setupVideoPlayer(media.asset!, completion: {})
                }
                return
            }
        }
        currentPlayerSetupIndex = -1
        videoPlayerView?.removeFromSuperview()
        videoPlayerView?.purgeVideoPlayer {}
    }
    
    private func updateCurrentVisibleIndex(){
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath: IndexPath = collectionView.indexPathForItem(at: visiblePoint){
            currentVisibleIndex = visibleIndexPath.item
        }
    }
    
    private func handleMediaCellActions(cell:TDMediaCell, indexPath: IndexPath){
        cell.onButtonTap { (buttonType) in
            if buttonType == .videoPlay{
                self.videoPlayerView?.isHidden = false
                self.videoPlayerView?.playVideo()
            }
        }
    }
    
    private func setUpMediaCell(mediaItem: TDPreviewViewModel, indexPath: IndexPath) -> TDMediaCell?{
        if mediaItem.asset?.mediaType == .image{
            return TDMediaCell.mediaCellWithType(.Image, collectionView: collectionView, for: indexPath)
        }
        if mediaItem.asset?.mediaType == .video{
            let cell =  TDMediaCell.mediaCellWithType(.Video, collectionView: collectionView, for: indexPath)
            handleMediaCellActions(cell: cell, indexPath: indexPath)
            return cell
        }
        return nil
    }
    
    private func configureMediaCell(item: TDPreviewViewModel, indexPath: IndexPath)-> UICollectionViewCell{
        
        let cell: TDMediaCell?
        cell = setUpMediaCell(mediaItem: item, indexPath: indexPath)
        
        if cell == nil{
            print("ERROR IN GENERATING CORRECT CELL")
            return UICollectionViewCell()
        }
        
        if item.mainImage != nil{
            cell?.configure(item.mainImage!)
        }
        else{
            cell?.configure(item.asset!, completionHandler: { (image) in
                item.mainImage = image
            })
        }
        
        return cell!
    }
    
    
    
    // MARK: - Collection View Datasource Method(s)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = mediaItems[(indexPath as NSIndexPath).item]
        if item.itemType == .Media{
            return configureMediaCell(item: item, indexPath: indexPath)
        }
        print("THIS SHOULD NOT BE CALLED. CHECK FOR ERROR")
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    // MARK: - Collection View Delegate Method(s)
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isScrolledByUser = true
    }
    
    // MARK: - ScrollView Delegate Method(s)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView{
            updateCurrentVisibleIndex()
            notifyScrolling()
            setupVideoPlayerView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setupVideoPlayerView()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setupVideoPlayerView()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setupVideoPlayerView()
    }
}

//MARK: - VideoPlayer Delegate Method(s)

extension TDMediaPreviewMainView: TDMediaVideoViewDelegate{
    
    func videoViewDidStopPlay(_ view: TDMediaVideoView) {
        
    }
    
}
extension TDMediaPreviewMainView{
    func viewWillAppear(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if let isHidden = self.dataSource?.previewMainViewHideCaptionView(self){
            captionTextView.isHidden = isHidden
        }
    }
    func viewDidDisappear(){
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = keyboardSize.height
            var duration = 0.3
            if let userInfo = notification.userInfo {
                duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
            }
            UIView.animate(withDuration: duration) {
                var captionBottomspace:CGFloat = self.bottomSpace - 5
                if UIApplication.shared.statusBarOrientation.isLandscape{
                    if captionBottomspace > 0{
                        captionBottomspace -= 40
                    }
                }
                self.captionTextViewBottomConstraint.constant = height-captionBottomspace
                self.layoutIfNeeded()
            }
        }
    }
    
    @objc private  func keyboardWillHide(notification: NSNotification) {
        var duration = 0.3
        if let userInfo = notification.userInfo {
            duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        }
        UIView.animate(withDuration: duration) {
            self.captionTextViewBottomConstraint.constant = 5
            self.layoutIfNeeded()
        }
    }
}
extension TDMediaPreviewMainView:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.updateTextViewFrame()
        mediaItems[selectedIndex].caption = textView.text
        self.delegate?.previewMainView(self, didRequestUpdateMedia : mediaItems[selectedIndex])
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let preText = textView.text else { return true }
        let newLength = preText.characters.count + text.characters.count - range.length
        return newLength <= captionCount
    }
}
