//
//  TDMediaPicker+Configurations.swift
//  Pods
//
//  Created by abhimanyujindal10 on 07/19/2017.
//  Copyright (c) 2017 abhimanyujindal10. All rights reserved.
//

import Foundation

//MARK:- CONFIGURATION METHOD(S)
extension TDMediaPicker{
    
    //MARK: - Public Method(s)
    
    func setupInitialConfiguration(){
        
        setupNavigationThemeConfig()
        setupMediaMaxSelectionConfig()
        setupAlbumScreenConfig()
        setupMediaScreenConfig()
        setupPreviewScreenConfig()
    }
    
    func getMediaPickerVideoThumbOverlay(_ picker: TDMediaPicker)-> TDConfigView?{
        return dataSource?.mediaPickerVideoThumbOverlay(self)
    }
    //MARK: ...Album Config Method(s)
    func getSelectedAlbumAtInitialLoad(albums: [TDAlbum]) -> TDAlbum? {
        return self.dataSource?.mediaPicker(self, selectedAlbumAtInitialLoad: albums)
    }
    
    func getAlbumText(album: TDAlbum, mediaCount: Int) -> TDConfigText? {
        return self.dataSource?.mediaPicker(self, textFormatForAlbum: album, mediaCount: mediaCount)
    }
    
    //MARK: ...Media Config Method(s)
    func getMediaHighlightedView(_ picker: TDMediaPicker, countForMedia mediaCount: Int)-> TDConfigView?{
        return self.dataSource?.mediaPicker(self, countForMedia: mediaCount)
    }
    
    //MARK: ...Preview Config Method(s)
    func getMediaPickerPreviewSelectedThumbnailView(_ picker: TDMediaPicker)-> TDConfigView?{
        return self.dataSource?.mediaPickerPreviewSelectedThumbnailView(self)
    }
    
    func getMediaPickerPreviewAddThumbnailView(_ picker: TDMediaPicker)-> TDConfigView?{
        return self.dataSource?.mediaPickerPreviewThumbnailAddView(self)
    }
    func getMediaPickerPreviewHideCaptionView(_ picker: TDMediaPicker) -> Bool? {
        return self.dataSource?.mediaPickerPreviewHideCaptionView(self)
    }
    
    //MARK: - Private Method(s)
    
    private func setupMediaMaxSelectionConfig(){
        if let maxSel = self.dataSource?.mediaPickerMaxSelections(self){
            serviceManager.setupConfig(maxSelections: maxSel)
        }else{
            serviceManager.setupConfig(maxSelections: TDMediaPickerConfig.defaultMaxSelection)
        }
    }
    
    private func setupNavigationThemeConfig(){
        if let theme = dataSource?.mediaPickerNavigationBarTheme(self){
            if let style = theme.style{
                navVC.navigationBar.barStyle = style
            }
            if let color = theme.color{
                navVC.navigationBar.barTintColor = color
            }
        }else{
            if let style = TDMediaPickerConfig.defaultNavigationTheme.style{
                navVC.navigationBar.barStyle = style
            }
            if let color = TDMediaPickerConfig.defaultNavigationTheme.color{
                navVC.navigationBar.barTintColor = color
            }
        }
    }
    
    //MARK: ...Album Config Method(s)

    private func setupAlbumScreenConfig(){
        var albumConfig = TDConfigAlbumScreen()
        if let navBarConfig = dataSource?.mediaPickerAlbumNavBarConfig(self){
            albumConfig.navigationBar = navBarConfig
        }
        if let fetchResult = dataSource?.mediaPickerFetchResultsForAlbumScreen(self){
            albumConfig.fetchResults = fetchResult
        }
        if let albumCollectionType = dataSource?.mediaPickerCollectionTypeForAlbumScreen(self){
            albumConfig.collectionType = albumCollectionType
        }
        if let size = dataSource?.mediaPickerImageSizeForAlbum(self){
            albumConfig.imageSize = size
        }
        if let mediaType = dataSource?.mediaPickerFilterMediaTpye(self){
            albumConfig.mediaType = mediaType
        }
        serviceManager.setupConfig(albumScreen: albumConfig)
    }
    
    //MARK: ...Media Config Method(s)
    
    private func setupMediaScreenConfig(){
        var mediaConfig = TDConfigMediaScreen()
        if let navBarConfig = dataSource?.mediaPickerMediaNavBarConfig(self){
            mediaConfig.navigationBar = navBarConfig
        }
        if let coulmn = dataSource?.mediaPickerMediaListNumberOfColumnInPortrait(self){
            mediaConfig.portraitColumns = coulmn
        }
        if let coulmn = dataSource?.mediaPickerMediaListNumberOfColumnInLandscape(self){
            mediaConfig.landscapeColumns = coulmn
        }
        serviceManager.setupConfig(mediaScreen: mediaConfig)
    }
    
    //MARK: ...Preview Config Method(s)
    
    private func setupPreviewScreenConfig(){
        var previewConfig = TDConfigPreviewScreen()
        if let navBarConfig = dataSource?.mediaPickerPreviewNavBarConfig(self){
            previewConfig.navigationBar = navBarConfig
        }
        if let videoThumbOverLay = dataSource?.mediaPickerVideoThumbOverlay(self){
            previewConfig.videoThumbOverlay = videoThumbOverLay
        }
        serviceManager.setupConfig(previewScreen: previewConfig)
    }
    
    
}
