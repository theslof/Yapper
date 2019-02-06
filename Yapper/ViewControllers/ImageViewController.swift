//
//  ImageViewController.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-01.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import UIKit

class ImageViewController: ThemedViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        self.view.backgroundColor = Theme.currentTheme.background
        
        activityIndicator.isHidden = false
        guard let url = imageURL else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = NSData(contentsOf: url)!
            DispatchQueue.main.async {
                let image = UIImage(data: imageData as Data)
                self.imageView.image = image
                self.activityIndicator.isHidden = true
            }
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBAction func actionDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
