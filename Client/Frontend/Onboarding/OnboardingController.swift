// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Foundation
import Common
import Shared

class OnboardingController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSetAsDefault: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    
    lazy var profile: Profile = BrowserProfile(
        localName: "profile",
        syncDelegate: UIApplication.shared.syncDelegate
    )
    
    var currentTheme: Theme?
    
    var index = 0
    var slides: [Slide] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.AppUtility.lockOrientation(.all)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    //  MARK: Custom Methods
    
    private func setupUI() {
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        
        view.bringSubviewToFront(pageControl)
        
        btnNext.layer.cornerRadius     = 4
        btnNext.layer.masksToBounds    = true
        
        applyTheme()
    }
    
    func applyTheme() {
        if let theme = currentTheme {
            viewBackground.backgroundColor = theme.colors.layer1
            
            switch theme.type {
            case .dark:
                lblDescription.textColor = .white
               
                btnSetAsDefault.tintColor = .white
                btnBack.tintColor = .white
                viewSeparator.backgroundColor = .white
            
                pageControl.tintColor = .white
                
            case .light:
                lblDescription.textColor = .blackColor
      
                btnSetAsDefault.tintColor = .blackColor
                btnBack.tintColor = .blackColor
                //viewSeparator.backgroundColor = .blackColor
                
                pageControl.tintColor = .blackColor
            }
        }
    }
    
    private func createSlides() -> [Slide] {
        if let currentTheme = currentTheme {
            let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide1.imageView.image = currentTheme.type == .light ? UIImage(named: "tutorial1") : UIImage(named: "tutorial1-dark")
            
            let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide2.imageView.image = currentTheme.type == .light ? UIImage(named: "tutorial2") : UIImage(named: "tutorial2-dark")
            
            let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide3.imageView.image = currentTheme.type == .light ? UIImage(named: "tutorial3") : UIImage(named: "tutorial3-dark")
            
            let slide4:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide4.imageView.image = currentTheme.type == .light ? UIImage(named: "tutorial4") : UIImage(named: "tutorial4-dark")
            
            let slide5:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide5.imageView.image = currentTheme.type == .light ? UIImage(named: "tutorial5") : UIImage(named: "tutorial5-dark")
            
            return [slide1, slide2, slide3, slide4, slide5]
        }
        
        return []
    }
    
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    //  MARK: UIScrollView Methods

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        index = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset

        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
            
            slides[0].imageView.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
            slides[1].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
            
        } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
            slides[1].imageView.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
            slides[2].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
            
        } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
            slides[2].imageView.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
            slides[3].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
            
        } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
            slides[3].imageView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
            slides[4].imageView.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }
    }

    func scrollView(_ scrollView: UIScrollView, didScrollToPercentageOffset percentageHorizontalOffset: CGFloat) {
        if(pageControl.currentPage == 0) {
            let pageUnselectedColor: UIColor = fade(fromRed: 255/255, fromGreen: 255/255, fromBlue: 255/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageControl.pageIndicatorTintColor = pageUnselectedColor
            
            let bgColor: UIColor = fade(fromRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1, toRed: 255/255, toGreen: 255/255, toBlue: 255/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            slides[pageControl.currentPage].backgroundColor = bgColor
            
            let pageSelectedColor: UIColor = fade(fromRed: 81/255, fromGreen: 36/255, fromBlue: 152/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageControl.currentPageIndicatorTintColor = pageSelectedColor
        }
    }
    
    func fade(fromRed: CGFloat,
              fromGreen: CGFloat,
              fromBlue: CGFloat,
              fromAlpha: CGFloat,
              toRed: CGFloat,
              toGreen: CGFloat,
              toBlue: CGFloat,
              toAlpha: CGFloat,
              withPercentage percentage: CGFloat) -> UIColor {
        
        let red: CGFloat = (toRed - fromRed) * percentage + fromRed
        let green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen
        let blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue
        let alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
        
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    //  MARK: Action Methods
    
    @IBAction func btnNext(_ sender: Any) {
        index += 1
        
        if index == 5 {
            profile.prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
            
            dismiss(animated: true)
        }
        else {
            scrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(index), y: 0), animated: true)
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        profile.prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
        
        dismiss(animated: true)
    }
    
    @IBAction func btnSetDefaultBrowser(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }
    
    @IBAction func pageControlAction(_ sender: UIPageControl) {
        scrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(sender.currentPage), y: 0), animated: true)
    }
}


