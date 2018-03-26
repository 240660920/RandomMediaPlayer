//
//  VideoWebViewController.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/9.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit

class VideoWebViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    
    var url: String = ""
    
    @IBAction func close(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.webview.loadRequest(URLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
