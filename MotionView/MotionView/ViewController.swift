//
//  ViewController.swift
//  MotionView
//
//  Created by 轻舟 on 2021/6/15.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.cornerRadius = 10
        self.imageView.clipsToBounds = true
        
        // 可以通过调节采样间隔以及最大旋转的角度控制，如果出现锯齿边缘，调节相机的透视距离
        self.imageView.startRotate3DWithDeviceMotion(angle: 0.5)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        motionKit.stopDeviceMotionUpdates()
    }


}

