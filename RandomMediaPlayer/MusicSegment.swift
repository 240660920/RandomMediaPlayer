//
//  MusicSegment.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/6.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit

enum MusicListType {
    case kRecommend
    case kLike
}

class MusicSegment: UIView {

    var clickBlock: ((MusicListType)->())?
    
    @IBOutlet weak var recommendBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.recommendBtn.layer.opacity = 1
        self.likeBtn.layer.opacity = 0.5
    }
    
    @IBAction func click(_ sender: UIButton) {
        if sender == self.recommendBtn{
            if self.recommendBtn.layer.opacity == 1 {
                return
            }
            self.likeBtn.layer.opacity = 0.5
            self.recommendBtn.layer.opacity = 1
            
            self.clickBlock?(.kRecommend)
        } else {
            if self.likeBtn.layer.opacity == 1 {
                return
            }
            self.recommendBtn.layer.opacity = 0.5
            self.likeBtn.layer.opacity = 1
            
            self.clickBlock?(.kLike)
        }
    }
}
