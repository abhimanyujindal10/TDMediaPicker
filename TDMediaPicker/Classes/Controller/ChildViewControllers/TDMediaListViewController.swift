//
//  TDMediaListViewController.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 26/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import UIKit

protocol TDMediaListViewControllerDataSource: class {
    func mediaController(_ view: TDMediaListViewController, countForMedia mediaCount: Int)-> TDConfigView?
    func mediaControllerVideoThumbOverlay(_ view: TDMediaListViewController)-> TDConfigView?
}

protocol TDMediaListViewControllerDelegate: class {
    func mediaControllerDidTapDone(_ view: TDMediaListViewController)
    func mediaControllerDidTapCancel(_ view: TDMediaListViewController)
}


class TDMediaListViewController: UIViewController, TDMediaListViewDelegate, TDMediaListServiceManagerDelegate,TDMediaListViewDataSource{
    
    // MARK: - Variable(s)
    
    private var selectedAlbum:TDAlbum?
    
    weak var delegate: TDMediaListViewControllerDelegate?
    weak var dataSource: TDMediaListViewControllerDataSource?
    
    lazy fileprivate var serviceManager: TDMediaListServiceManager = TDMediaListServiceManager()
    
    // MARK: - Init
    
    public required init() {
        super.init(nibName: "TDMediaList", bundle: TDMediaUtil.xibBundle())
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let mediaView = self.view as! TDMediaListView
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            mediaView.viewDidTransition()
        })
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. View Setup
        
        let mediaView = self.view as! TDMediaListView
        mediaView.setupView()
        mediaView.delegate = self
        mediaView.dataSource = self
        
        // 2. Service Manager Setup
        
        serviceManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupNavigationTheme()
        setupConfig()
        
        if selectedAlbum != nil{
            serviceManager.fetchMediaItems(album: selectedAlbum!, completion: { (media) in
                self.handleFetchedMedia(media)
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        serviceManager.purgeData()
        
        let mediaView = self.view as! TDMediaListView
        mediaView.purgeData()
    }
    
    // MARK: - Public Method(s)
    
    func setupSelectedAlbum(_ album:TDAlbum){
        selectedAlbum = album
    }
    
    // MARK: - Private Method(s)
    
    private func handleFetchedMedia(_ mediaList:[TDMedia]){
        let mediaViewModels = mapMediaViewModels(mediaList: mediaList)
        let mediaView = self.view as! TDMediaListView
        mediaView.reload(media: mediaViewModels)
    }
    
    private func mapMediaViewModels(mediaList:[TDMedia])->[TDMediaViewModel]{
        var mediaViewModels: [TDMediaViewModel] = []
        for(_,media) in mediaList.enumerated(){
            let mediaViewModel = map(media)
            if mediaViewModel != nil{
                let mediaView = mediaViewModel as! TDMediaViewModel
                mediaViewModels.append(mediaView)
            }
        }
        return mediaViewModels
    }
    
    private func map<T>(_ from: T) -> AnyObject?{
        if from is TDMedia{
            let media = from as! TDMedia
            return TDMediaViewModel.init(id: media.id, asset: media.asset)
        }
        return nil
    }
    
    //MARK: - Media View Datasource Method(s)
    func mediaListView(_ view: TDMediaListView, countForMedia mediaCount: Int)-> TDConfigView?{
        return self.dataSource?.mediaController(self, countForMedia: mediaCount)
    }
    
    func mediaListViewVideoThumbOverlay(_ view: TDMediaListView)-> TDConfigView?{
        return self.dataSource?.mediaControllerVideoThumbOverlay(self)
    }
    // MARK: - View Delegate Method(s)
    
    func mediaListView(_ view: TDMediaListView, didSelectMedia media: TDMediaViewModel, shouldRemoveFromCart value: Bool) {
        serviceManager.fetchMedia(media.id) { (mediaDataModel) in
            if mediaDataModel == nil{
                return
            }
            if value{
                serviceManager.updateCart(mediaDataModel!, updateType: .delete)
                return
            }
            serviceManager.updateCart(mediaDataModel!, updateType: .add)
            if serviceManager.getConfig() == 1{
                self.delegate?.mediaControllerDidTapDone(self)
            }
        }
    }
    
    func mediaListViewDidTapBack(_ view: TDMediaListView) {
        self.delegate?.mediaControllerDidTapCancel(self)
    }
    
    func mediaListViewDidTapDone(_ view: TDMediaListView) {
        self.delegate?.mediaControllerDidTapDone(self)
    }
    
    
    // MARK: - Service Manager Delegate Method(s)
    
    
    func mediaListServiceManager(_ manager: TDMediaListServiceManager, didUpdateCart cart: TDCart, updateType: TDCart.UpdateType) {
        
        let mediaViewModels = mapMediaViewModels(mediaList: cart.media)
        let cartViewModel = TDCartViewModel.init(media: mediaViewModels)
        
        var cartViewUpdateType: TDCartViewModel.UpdateType = .none
        
        switch updateType {
        case .add:
            cartViewUpdateType = .add
        case .delete:
            cartViewUpdateType = .delete
        case .purgeCache:
            cartViewUpdateType = .purgeCache
        case .reload:
            cartViewUpdateType = .reload
        case .edit:
            cartViewUpdateType = .edit
        }
        
        let mediaView = self.view as! TDMediaListView
        mediaView.reload(cart: cartViewModel, updateType: cartViewUpdateType)
    }
    
    func mediaListServiceManager(_ manager: TDMediaListServiceManager, cartmaximumUpdate maxCount:Int){
        
        let alertController = UIAlertController(title: "", message: "Maximum \(maxCount) items please!", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        self.perform(#selector(hideAlert), with: alertController, afterDelay: 1)
        
    }
    
    func hideAlert(alertCntroller: UIAlertController){
        alertCntroller.dismiss(animated: true, completion: nil)
    }
    
}
// MARK: - Configurations

extension TDMediaListViewController{
    
    func setupNavigationTheme(){
        let config = serviceManager.getNavigationThemeConfig()
        let mediaView = self.view as! TDMediaListView
        mediaView.setupNavigationTheme(config.backgroundColor)
    }
    
    func setupConfig(){
        let mediaView = self.view as! TDMediaListView
        let config = serviceManager.getMediaScreenConfig()
        if let title = config.navigationBar?.screenTitle{
            mediaView.setupScreenTitle(title)
        }
        if let btnConfig = config.navigationBar?.backButton{
            mediaView.setupBackButton(btnConfig)
        }
        if let btnConfig = config.navigationBar?.nextButton{
            mediaView.setupNextButton(btnConfig)
        }
        if let color = config.navigationBar?.navigationBarView?.backgroundColor{
            mediaView.setupNavigationTheme(color)
        }
        if let column = config.portraitColumns{
            mediaView.setupMediaNumberOfColumnForPotrait(column)
        }
        if let column = config.landscapeColumns{
            mediaView.setupMediaNumberOfColumnForLandscape(column)
        }
    }
}
