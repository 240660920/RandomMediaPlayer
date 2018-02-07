//
//  MusicControlView.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/5.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit

class MusicControlView: UIView {

    var playBlock: ((_ isPlaying: Bool) -> (Bool))?
    var deleteBlock: (()->())?
    var favorBlock: ((_ isFavor: Bool)->(Bool))?

    let playBtn = UIButton()
    let deleteBtn = UIButton()
    let favorBtn = UIButton()

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    init() {
        super.init(frame: .zero)
        
        playBtn.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        playBtn.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .selected)
        playBtn.addTarget(self, action: #selector(play(sender:)), for: .touchUpInside)
        addSubview(playBtn)
        playBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(58)
        }
        
        deleteBtn.setBackgroundImage(#imageLiteral(resourceName: "delete"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteFunc), for: .touchUpInside)
        addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
        }
        
        favorBtn.setBackgroundImage(#imageLiteral(resourceName: "like_normal"), for: .normal)
        favorBtn.setBackgroundImage(#imageLiteral(resourceName: "like_selected"), for: .selected)
        favorBtn.addTarget(self, action: #selector(favor(sender:)), for: .touchUpInside)
        addSubview(favorBtn)
        favorBtn.snp.makeConstraints { (make) in
            make.right.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func play(sender: UIButton) {        
        let result = self.playBlock?(!sender.isSelected)
        sender.isSelected = result ?? false
    }
    
    @objc func deleteFunc() {
        self.deleteBlock?()
    }
    
    @objc func favor(sender: UIButton) {
        let result = self.favorBlock?(!sender.isSelected)
        
        sender.isSelected = result ?? false
    }
    
    func play() {
        playBtn.isSelected = true
    }
    
    func pause() {
        playBtn.isSelected = false
    }
    
    func setFavor(_ isFavor: Bool) {
        self.favorBtn.isSelected = isFavor
    }
}
