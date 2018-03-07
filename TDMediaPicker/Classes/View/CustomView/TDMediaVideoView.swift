//
//  TDMediaVideoView.swift
//  Pods
//
//  Created by Abhimanu Jindal on 27/07/17.
//
//

import UIKit
import Photos

protocol TDMediaVideoViewDelegate {
    func videoViewDidStopPlay(_ view:TDMediaVideoView)
}

class TDMediaVideoView: UIView {
    
    // MARK: - Variable(s)
    
    private var avPlayerLayer: AVPlayerLayer?
    private var avPlayer: AVPlayer?
    private var asset: PHAsset?
    var delegate: TDMediaVideoViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Video Deinit")
    }
    // MARK: - Public Method(s)
    
    func playVideo(){
        self.isHidden = false
        self.avPlayer?.play()
    }
    
    func stopVideo(){
        self.isHidden = true
        self.avPlayer?.pause()
        self.avPlayer?.seek(to: kCMTimeZero)
    }
    
    func pause(){
        self.isHidden = true
        self.avPlayer?.pause()
    }
    
    func purgeVideoPlayer(_ completion: @escaping () -> Void){
        if self.avPlayerLayer != nil{
            self.purgeVideoLayer {
                completion()
            }
            return
        }
        completion()
    }
    
    func setupVideoPlayer(_ asset: PHAsset, completion: @escaping () -> Void){
        self.asset = asset
        self.setupPlayer {
            self.isHidden = true
            completion()
        }
    }
    
    // MARK: - Private Method(s)
    
    private func setupPlayer(_ completion: @escaping () -> Void){
        TDMediaUtil.fetchPlayerItem(self.asset!) { (playerItem) in
            
            if playerItem != nil{
                
                self.avPlayer = AVPlayer(playerItem: playerItem!)
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
                self.avPlayerLayer!.frame = self.bounds
                self.avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
                self.layer.addSublayer(self.avPlayerLayer!)
                completion()
            }
        }
    }
    
    private func purgeVideoLayer(_ completion: @escaping () -> Void){
        self.avPlayerLayer?.removeFromSuperlayer()
        avPlayerLayer = nil
        stopVideo()
        avPlayer = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        completion()
    }
    
    @objc private func playerItemDidPlayToEndTime(){
        stopVideo()
        self.delegate?.videoViewDidStopPlay(self)
    }

}
