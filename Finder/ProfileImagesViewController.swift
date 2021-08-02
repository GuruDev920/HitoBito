//
//  ProfileImagesViewController.swift
//  Finder
//
//  Created by Tai on 6/17/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit
import ImageSlideshow

class ProfileImagesViewController: UIViewController {

    @IBOutlet var slideshow: ImageSlideshow!
    @IBOutlet weak var constraintSlideBottom: NSLayoutConstraint!
    
    var images: [UIImage] = []
    var curIndex = 0
    
    private var localSource: [ImageSource] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for image in self.images {
            localSource.append(ImageSource(image: image))
        }
        
        constraintSlideBottom.constant = self.images.count >= 2 ? 0 : -30
        
        slideshow.slideshowInterval = 0.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        slideshow.pageIndicator = pageControl

        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self

        slideshow.setImageInputs(localSource)
        
        slideshow.setCurrentPage(self.curIndex, animated: false)
        
        let tapOnSlideshow = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnSlideshow))
        slideshow.addGestureRecognizer(tapOnSlideshow)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Global_ShowFrostGlass(self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Global_HideFrostGlass()
    }
    
    @objc func didTapOnSlideshow() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    @IBAction func onBtnClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileImagesViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
