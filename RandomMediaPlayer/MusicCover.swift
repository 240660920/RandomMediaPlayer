//
//  MusicCover.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/5.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit

class MusicCover: UIView {

    let imageLayer = CALayer()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
     
        imageLayer.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        imageLayer.cornerRadius = rect.width / 2
        imageLayer.backgroundColor = UIColor.clear.cgColor
        imageLayer.masksToBounds = true
        layer.addSublayer(imageLayer)
        
        let outerCircle = CAShapeLayer()
        outerCircle.fillColor = UIColor.clear.cgColor
        outerCircle.lineWidth = 6
        outerCircle.strokeColor = UIColor(red: 73.0/255.0, green: 73.0/255.0, blue: 73.0/255.0, alpha: 0.6).cgColor
        outerCircle.path = UIBezierPath(arcCenter: CGPoint(x: rect.width / 2, y: rect.height / 2), radius: rect.width / 2 - 3, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
        layer.addSublayer(outerCircle)
        
        let innerCircle = CAShapeLayer()
        innerCircle.fillColor = UIColor.clear.cgColor
        innerCircle.lineWidth = 6
        innerCircle.strokeColor = UIColor(red: 84.0/255.0, green: 84.0/255.0, blue: 84.0/255.0, alpha: 0.3).cgColor
        innerCircle.path = UIBezierPath(arcCenter: CGPoint(x: rect.width / 2, y: rect.height / 2), radius: rect.width / 2 - 9, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
        layer.addSublayer(innerCircle)
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startRotating() {
        if self.imageLayer.animation(forKey: "rotate") == nil {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = acos(self.layer.affineTransform().a)
            animation.toValue = acos(self.layer.affineTransform().a) + CGFloat(Double.pi * 2)
            animation.duration = 15
            animation.repeatCount = MAXFLOAT
            animation.isRemovedOnCompletion = false
            self.imageLayer.add(animation, forKey: "rotate")
            return
        }
        
        let pausedTime = self.imageLayer.timeOffset;
        self.imageLayer.speed = 1.0;
        self.imageLayer.timeOffset = 0.0;
        self.imageLayer.beginTime = 0.0;
        let timeSincePause = self.imageLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime;
        self.imageLayer.beginTime = timeSincePause;
    }
    
    func stopRotating() {
        let pauseTime = self.imageLayer.convertTime(CACurrentMediaTime(), from: nil)
        self.imageLayer.speed = 0
        self.imageLayer.timeOffset = pauseTime
    }
}
