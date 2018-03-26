//
//  VideoTableViewCell.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/7.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit



class VideoTableViewCell: UITableViewCell {

    static let videoThumHeight = 37.0 / 66.0 * ((UIApplication.shared.keyWindow?.frame.width)! - 46)
    
    var thumbnailImageView = UIImageView()
    var descLabel = UILabel()
    var authorLabel = UILabel()
    var timeLabel = UILabel()
    var playBtn = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(VideoTableViewCell.videoThumHeight)
        }
        
        contentView.addSubview(descLabel)
        descLabel.numberOfLines = 0
        descLabel.textColor = UIColor.white
        descLabel.font = UIFont.systemFont(ofSize: 10)
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        let infoMask = UIView()
        infoMask.backgroundColor = UIColor(white: 0, alpha: 0.44)
        contentView.addSubview(infoMask)
        infoMask.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(thumbnailImageView)
            make.height.equalTo(28)
        }
        
        authorLabel.textColor = UIColor.white
        authorLabel.font = UIFont.systemFont(ofSize: 10)
        infoMask.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
        }
        
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        timeLabel.textAlignment = .right
        infoMask.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(playBtn)
        playBtn.image = #imageLiteral(resourceName: "play")
        playBtn.layer.opacity = 0.74
//        playBtn.addTarget(self, action: #selector(play), for: .touchUpInside)
        playBtn.snp.makeConstraints { (make) in
            make.center.equalTo(thumbnailImageView)
            make.width.height.equalTo(50)
        }
    }
    
    static func getCellHeight(ofText text: String) -> CGFloat {
        let textHeight = (text as NSString).boundingRect(with: CGSize(width: (UIApplication.shared.keyWindow?.frame.width)! - 70, height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)], context: nil).size.height
        return videoThumHeight + textHeight + 10 * 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
