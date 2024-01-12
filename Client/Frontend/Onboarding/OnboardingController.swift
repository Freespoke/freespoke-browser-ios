// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Foundation
import Common
import Shared
import OneSignal

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
    @IBOutlet weak var imgViewBackground: UIImageView!
    
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
    
    // MARK: Custom Methods
    
    private func setupUI() {
        guard let currentTheme = currentTheme else { return }
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        
        view.bringSubviewToFront(pageControl)
        
        btnNext.layer.cornerRadius     = 4
        btnNext.layer.masksToBounds    = true
        
        let firstLine = "Search better, browse better:"
        
        let foregroundColor = currentTheme.type == .light ? UIColor.blackColor : UIColor.whiteColor
        let firstLineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SourceSansPro-Bold", size: 18)!,
            .foregroundColor: foregroundColor
        ]
        let firstLineAttributedString = NSAttributedString(string: firstLine, attributes: firstLineAttributes)
        
        // Second line with underlined text
        let secondLine = "\nSet Freespoke as your default browser."
        let secondLineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SourceSansPro-Regular", size: 18)!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: foregroundColor
        ]
        let secondLineAttributedString = NSAttributedString(string: secondLine, attributes: secondLineAttributes)
        
        // Combine both lines into a single attributed string
        let buttonText = NSMutableAttributedString()
        buttonText.append(firstLineAttributedString)
        buttonText.append(secondLineAttributedString)
        
        // Set the attributed text to the button
        btnSetAsDefault.setAttributedTitle(buttonText, for: .normal)
        btnSetAsDefault.titleLabel?.textAlignment = .center
        btnSetAsDefault.alpha = 1
        applyTheme()
    }
    
    func applyTheme() {
        if let theme = currentTheme {
            //viewBackground.backgroundColor = theme.colors.layer1
            
            switch theme.type {
            case .dark:
                btnSetAsDefault.setTitleColor(.white, for: .normal)
                btnBack.tintColor = .white
                
                pageControl.tintColor = .white
                
                viewBackground.backgroundColor = .onboardingDark
                imgViewBackground.backgroundColor = .onboardingDark
                
                imgViewBackground.image = UIImage(named: "onboarding-dark")
                
            case .light:
                btnSetAsDefault.setTitleColor(.blackColor, for: .normal)
                btnBack.tintColor = .blackColor
                
                pageControl.tintColor = .blackColor
                
                viewBackground.backgroundColor = .white
                imgViewBackground.backgroundColor = .white
                
                imgViewBackground.image = UIImage(named: "onboarding")
            }
        }
    }
    
    private func setTheme(isDark: Bool) {
        if !isDark {
            btnSetAsDefault.setTitleColor(.blackColor, for: .normal)
            btnBack.tintColor = .blackColor
            
            pageControl.tintColor = .blackColor
            
            viewBackground.backgroundColor = .onboardingDark
            imgViewBackground.backgroundColor = .onboardingDark
            
            imgViewBackground.image = UIImage(named: "onboarding-dark")
        }
        else {
            //btnSetAsDefault.tintColor = .white
            btnSetAsDefault.setTitleColor(.white, for: .normal)
            btnBack.tintColor = .white
            
            pageControl.tintColor = .white
            
            viewBackground.backgroundColor = .white
            imgViewBackground.backgroundColor = .white
            
            imgViewBackground.image = UIImage(named: "onboarding")
        }
    }
    
    private func createSlides() -> [Slide] {
        if let currentTheme = currentTheme {
            let slide1: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide1.imageView.image = currentTheme.type == .light ? UIImage(named: "onboarding") : UIImage(named: "onboarding-dark")
            slide1.lblFirstTitle.text = "Welcome to \nFreespoke"
            
            // first part with regular text
            let firstPart = "Get Full-Perspective and Full Anonymity When You Search.\n\n\n\n"
            
            let foregroundColor = currentTheme.type == .light ? UIColor.blackColor : UIColor.whiteColor
            let firstPartAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "SourceSansPro-Regular", size: 16)!,
                .foregroundColor: foregroundColor
            ]
            let firstPartAttributedString = NSAttributedString(string: firstPart, attributes: firstPartAttributes)
            
            // Second part with bold text
            let secondPart = "Search you can trust."
            let secondPartAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "SourceSansPro-Bold", size: 16)!,
                .foregroundColor: foregroundColor
            ]
            let secondPartAttributedString = NSAttributedString(string: secondPart, attributes: secondPartAttributes)
            
            // Combine both lines into a single attributed string
            let descText = NSMutableAttributedString()
            descText.append(firstPartAttributedString)
            descText.append(secondPartAttributedString)
            // Set the attributed text to the label
            slide1.lblFirstDesc.attributedText = descText
            
            slide1.lblFirstTitle.textColor = currentTheme.type == .light ? .onboardingTitleDark : UIColor.white
            slide1.lblFirstDesc.textColor = currentTheme.type == .light ? .blackColor : .whiteColor
            slide1.imageView.isHidden = false
            slide1.viewSecondSlide.isHidden = true
            slide1.lblFirstTitle.isHidden = false
            slide1.lblFirstDesc.isHidden = false
            
            let slide2: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            //            slide2.delegate = self
            slide2.imageView.image = currentTheme.type == .light ? UIImage(named: "onboarding0") : UIImage(named: "onboarding0-dark")
            slide2.lblTitle.text = "Newsfeed"
            slide2.lblDesc.text = "Navigating the news is tough. We help you quickly get the full story by labeling media sources so you can see stories covered from different perspectives."
            slide2.lblTitle.textColor = currentTheme.type == .light ? .onboardingTitleDark : UIColor.white
            slide2.lblDesc.textColor = currentTheme.type == .light ? .blackColor : .whiteColor
            slide2.imageView.isHidden = false
            slide2.viewSegments.isHidden = false
            
            let slide3: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide3.imageView.image = currentTheme.type == .light ? UIImage(named: "onboarding1") : UIImage(named: "onboarding1-dark")
            slide3.lblTitle.text = "Elections"
            slide3.lblDesc.text = "Explore the Freespoke election portal featuring the latest voting information, breaking news, and elections results."
            slide3.lblTitle.textColor = currentTheme.type == .light ? .onboardingTitleDark : UIColor.white
            slide3.lblDesc.textColor = currentTheme.type == .light ? .blackColor : .whiteColor
            
            let slide4: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide4.imageView.image = currentTheme.type == .light ? UIImage(named: "onboarding2") : UIImage(named: "onboarding2-dark")
            slide4.lblTitle.text = "Search"
            slide4.lblDesc.text = "We provide quality search so you can easily find results from all perspectives, while protecting your privacy with every search."
            slide4.lblTitle.textColor = currentTheme.type == .light ? .onboardingTitleDark : UIColor.white
            slide4.lblDesc.textColor = currentTheme.type == .light ? .blackColor : .whiteColor
            
            let slide5: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide5.imageView.image = currentTheme.type == .light ? UIImage(named: "onboarding3") : UIImage(named: "onboarding3-dark")
            slide5.lblTitle.text = "Tabs"
            slide5.lblDesc.text = "Save your favorite content all in once place. Making it quicker to pick up where you left off, or frequent your favorite websites and search results. "
            slide5.lblTitle.textColor = currentTheme.type == .light ? .onboardingTitleDark : UIColor.white
            slide5.lblDesc.textColor = currentTheme.type == .light ? .blackColor : .whiteColor
            
            return [slide1, slide2, slide3, slide4, slide5]
        }
        
        return []
    }
    
    func setupSlideScrollView(slides: [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    // MARK: UIScrollView Methods
    
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
            
            slides[0].viewBackground.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
            slides[1].viewBackground.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
            
        } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
            slides[1].viewBackground.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
            slides[2].viewBackground.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
            
        } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
            slides[2].viewBackground.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
            slides[3].viewBackground.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
            
        } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
            slides[3].viewBackground.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
            slides[4].viewBackground.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
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
    
    // MARK: Action Methods
    
    @IBAction func btnNext(_ sender: Any) {
        
        index += 1
        
        switch index {
        case 1:
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut,
                           animations: {
                self.btnNext.setTitle("Next", for: .normal)
                self.imgViewBackground.alpha = 0
            })
            
        case 4:
            //|     Ask for setup notification setting
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notification: \(accepted)")
            })
        default:
            break
        }
        
        if index == 5 {
            profile.prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
            
            self.dismiss(animated: true)
        }
        else {
            scrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(index), y: 0), animated: true)
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        profile.prefs.setInt(1, forKey: PrefsKeys.IntroSeen)
        
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSetDefaultBrowser(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }
    
    @IBAction func pageControlAction(_ sender: UIPageControl) {
        scrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(sender.currentPage), y: 0), animated: true)
    }
}
