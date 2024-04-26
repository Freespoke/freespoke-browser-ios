// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import Storage
import Common
import Kingfisher
import SwiftyJSON
import Shared

protocol FreespokeHomepageDelegate {
    func didPressSearch()
    func didPressBookmarks()
    func didPressRecentlyViewed()
    func showURL(url: String)
}

class FreespokeHomepage: UIView {
    let kCONTENT_XIB_NAME = "FreespokeHomepage"
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var constScrollViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var constBookmarksHeight: NSLayoutConstraint!
    @IBOutlet weak var constViewTrendingNewsHeight: NSLayoutConstraint!
    @IBOutlet weak var constShopUsaHeight: NSLayoutConstraint!
    @IBOutlet weak var constRecentlyViewedHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewBookmarks: UICollectionView!
    @IBOutlet weak var collectionViewTrendingNews: UICollectionView!
    @IBOutlet weak var collectionViewRecentlyViewd: UICollectionView!
    @IBOutlet weak var collectionViewShopUsa: UICollectionView!
    
    @IBOutlet weak var imgViewFreespoke: UIImageView!
    @IBOutlet weak var lblFreespoke: UILabel!
    @IBOutlet weak var btnSerch: UIButton!
    @IBOutlet weak var imgViewSearch: UIImageView!
    
    @IBOutlet weak var viewFreespokeWay: UIView!
    @IBOutlet weak var viewBookmarks: UIView!
    @IBOutlet weak var viewTrendingNews: UIView!
    @IBOutlet weak var viewRecentlyViewed: UIView!
    @IBOutlet weak var viewShopUsa: UIView!
    @IBOutlet weak var viewSeparator: UIView!
    
    @IBOutlet weak var imgViewBookmarks: UIImageView!
    @IBOutlet weak var imgViewTrendingNews: UIImageView!
    @IBOutlet weak var imgViewRecentlyViewed: UIImageView!
    @IBOutlet weak var imgViewShopUsa: UIImageView!
    
    @IBOutlet weak var lblFreespokeWay: UILabel!
    @IBOutlet weak var lblBookmarks: UILabel!
    @IBOutlet weak var lblTrendingNews: UILabel!
    @IBOutlet weak var lblRecentlyViewed: UILabel!
    @IBOutlet weak var lblShopUsa: UILabel!
    
    @IBOutlet weak var btnBookmarks: UIButton!
    @IBOutlet weak var btnTrendingNews: UIButton!
    @IBOutlet weak var btnRecentlyViewed: UIButton!
    @IBOutlet weak var btnShopUsa: UIButton!
    
    @IBOutlet weak var imgViewFreespokeWayUp: UIImageView!
    @IBOutlet weak var imgViewFreespokeWayMiddle: UIImageView!
    @IBOutlet weak var imgViewFreespokeWayDown: UIImageView!
    
    @IBOutlet weak var btnFreespokeWayUp: UIButton!
    @IBOutlet weak var btnFreespokeWayMiddle: UIButton!
    @IBOutlet weak var btnFreespokeWayDown: UIButton!
    
    @IBOutlet weak var avatarView: UIView!
    
    private var profileIconView = ProfileIconView()
    
    var profileIconTapClosure: (() -> Void)?
    
    var delegate: FreespokeHomepageDelegate?
    
    private var bookmarksHandler: BookmarksHandler?
    
    var profile: Profile!
    var arrBookmarks = [Site]()
    var arrRecenlyViewed = [HighlightItem]()
    var arrTrendingStory = [TrendingStory]()
    var arrShoppingCollection: [ShoppingCoollectionItemModel] = []
    
    var urlSearch       = ""
    var urlTrending     = ""
    var urlShopping     = ""
    
    var pageTrending = 1
    var pageShoppping = 1
    
    let yourAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "SourceSansPro-Regular", size: 14)!,
        .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    let margin: CGFloat = 8
    
    private var networkManager = NetworkManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setUI()
        addProfileIconView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        
        initCollectionView()
    }
    
    func applyTheme(currentTheme: Theme) {
        self.profileIconView.applyTheme(currentTheme: currentTheme)
    }
    
    func addProfileIconView() {
        self.avatarView.addSubview(self.profileIconView)
        self.profileIconView.translatesAutoresizingMaskIntoConstraints = false
        
        self.profileIconView.pinToView(view: self.avatarView)
        
        profileIconView.tapClosure = { [weak self] in
            self?.profileIconTapClosure?()
        }
    }
    
    func updateView(decodedJWTToken: FreespokeJWTDecodeModel?) {
        self.profileIconView.updateView(decodedJWTToken: decodedJWTToken)
    }
    
    private func initCollectionView() {
        let bookmarkCellIdentifier = UINib(nibName: "BookmarkCollectionViewCell", bundle: nil)
        collectionViewBookmarks.register(bookmarkCellIdentifier, forCellWithReuseIdentifier: "bookmarkCellIdentifier")
        
        let recentlyViewedCellIdentifier = UINib(nibName: "RecentlyViewedCollectionViewCell", bundle: nil)
        collectionViewRecentlyViewd.register(recentlyViewedCellIdentifier, forCellWithReuseIdentifier: "recentlyViewedCellIdentifier")
        
        let trendingNewsCellIdentifier = UINib(nibName: "TrendingNewsCollectionViewCell", bundle: nil)
        collectionViewTrendingNews.register(trendingNewsCellIdentifier, forCellWithReuseIdentifier: "trendingNewsCellIdentifier")
        
        let shopUsaCellIdentifier = UINib(nibName: "ShopUsaCollectionViewCell", bundle: nil)
        collectionViewShopUsa.register(shopUsaCellIdentifier, forCellWithReuseIdentifier: "shopUsaCellIdentifier")
        
        guard let collectionView = collectionViewShopUsa, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        
        guard let collectionView = collectionViewTrendingNews, let flowLayoutT = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayoutT.minimumInteritemSpacing = 20
        flowLayoutT.minimumLineSpacing = 20
        flowLayoutT.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
    }
    
    func updateUI() {
        setupScrollViewWidth()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.collectionViewShopUsa.reloadData()
            self.collectionViewTrendingNews.reloadData()
        }
    }
    
    private func setupScrollViewWidth() {
        //| Scroll view dimension
        if UIWindow.isLandscape {
            
            //|     Check if the device has notch and set it to the scroll view
            if UIDevice.current.hasNotch {
                if let topNotch = UIApplication.shared.keyWindow?.safeAreaInsets.top,
                   let leftNotch = UIApplication.shared.keyWindow?.safeAreaInsets.left {
                    
                    constScrollViewWidth.constant = topNotch > leftNotch ? UIScreen.main.bounds.size.width - (topNotch * 2) : UIScreen.main.bounds.size.width - (leftNotch * 2)
                }
                else {
                    constScrollViewWidth.constant = UIScreen.main.bounds.size.width - 100
                }
            }
            else {
                constScrollViewWidth.constant = UIScreen.main.bounds.size.width
            }
        }
        else {
            constScrollViewWidth.constant = UIScreen.main.bounds.size.width
        }
    }
    
    func setUI() {
        setupScrollViewWidth()
        
        btnSerch.layer.cornerRadius     = 8
        btnSerch.layer.borderWidth      = 1
        btnSerch.layer.masksToBounds    = true
        
        viewFreespokeWay.layer.cornerRadius     = 8
        viewFreespokeWay.layer.borderWidth      = 1
        viewFreespokeWay.layer.masksToBounds    = true
        
        viewBookmarks.layer.cornerRadius     = 8
        viewBookmarks.layer.borderWidth      = 1
        viewBookmarks.layer.masksToBounds    = true
        
        viewTrendingNews.layer.cornerRadius     = 8
        viewTrendingNews.layer.borderWidth      = 1
        viewTrendingNews.layer.masksToBounds    = true
        
        viewRecentlyViewed.layer.cornerRadius     = 8
        viewRecentlyViewed.layer.borderWidth      = 1
        viewRecentlyViewed.layer.masksToBounds    = true
        
        viewShopUsa.layer.cornerRadius     = 8
        viewShopUsa.layer.borderWidth      = 1
        viewShopUsa.layer.masksToBounds    = true
        
        btnFreespokeWayUp.layer.cornerRadius     = 8
        btnFreespokeWayUp.layer.borderWidth      = 1
        btnFreespokeWayUp.layer.masksToBounds    = true
        
        btnFreespokeWayMiddle.layer.cornerRadius     = 8
        btnFreespokeWayMiddle.layer.borderWidth      = 1
        btnFreespokeWayMiddle.layer.masksToBounds    = true
        
        btnFreespokeWayDown.layer.cornerRadius     = 8
        btnFreespokeWayDown.layer.borderWidth      = 1
        btnFreespokeWayDown.layer.masksToBounds    = true
        
        btnBookmarks.layer.cornerRadius     = 4
        btnBookmarks.layer.masksToBounds    = true
        
        btnTrendingNews.layer.cornerRadius     = 4
        btnTrendingNews.layer.masksToBounds    = true
        
        btnRecentlyViewed.layer.cornerRadius     = 4
        btnRecentlyViewed.layer.masksToBounds    = true
        
        btnShopUsa.layer.cornerRadius     = 4
        btnShopUsa.layer.masksToBounds    = true
        
        pageTrending = 1
        pageShoppping = 1
        
        getTrendngStory(page: pageTrending)
        getShopppingCollection(page: pageShoppping)
        getFreespokeWaySection()
    }
    
    func reloadAllItems() {
        getRecentBookmarks()
        
        pageTrending = 1
        pageShoppping = 1
        
        getTrendngStory(page: pageTrending)
        getShopppingCollection(page: pageShoppping)
        
        collectionViewRecentlyViewd.reloadData()
    }
    
    func getRecentBookmarks() {
        profile.places.searchBookmarks(query: "", limit: 100).upon { result in
            guard let bookmarkItems = result.successValue else {
                return
            }
            
            let sites = bookmarkItems.map({ Site(url: $0.url, title: $0.title, bookmarked: true, guid: $0.guid) }).reversed()
            
            self.arrBookmarks = [Site]()
            self.arrBookmarks.append(contentsOf: sites)
            
            DispatchQueue.main.async {
                self.collectionViewBookmarks.reloadData()
            }
        }
    }
    
    // MARK: - API Methods
    
    func getFreespokeWaySection() {
        let url = NSURL(string: "https://api.freespoke.com/app/freespoke/widgets/quick-links?limit=3&client=ios")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if error != nil {
            }
            else {
                do {
                    let json = try JSON(data: data!)
                    
                    let data = json["data"]
                    let title = json["label"].stringValue
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.lblFreespokeWay.text = json["label"].stringValue
                    }
                    
                    if let arrStory = data.array {
                        if !arrStory.isEmpty {
                            
                            for story in arrStory {
                                
                                switch story["category"].stringValue {
                                case "Search":
                                    self.urlSearch = story["url"].stringValue
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                        self.btnFreespokeWayUp.setTitle(story["title"].stringValue, for: .normal)
                                        
                                        let url = URL(string: story["categoryIcon"].stringValue)
                                        
                                        self.imgViewFreespokeWayUp.kf.setImage(with: url)
                                    }
                                    
                                case "Shop":
                                    self.urlShopping = story["url"].stringValue
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                        self.btnFreespokeWayMiddle.setTitle(story["title"].stringValue, for: .normal)
                                        
                                        let url = URL(string: story["categoryIcon"].stringValue)
                                        
                                        self.imgViewFreespokeWayMiddle.kf.setImage(with: url)
                                    }
                                    
                                case "News":
                                    self.urlTrending = story["url"].stringValue
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                        self.btnFreespokeWayDown.setTitle(story["title"].stringValue, for: .normal)
                                        
                                        let url = URL(string: story["categoryIcon"].stringValue)
                                        
                                        self.imgViewFreespokeWayDown.kf.setImage(with: url)
                                    }
                                    
                                default:
                                    break
                                    
                                }
                            }
                        }
                    }
                }
                catch {
                    print("error")
                }
            }
        }
        dataTask.resume()
    }
    
    func getTrendngStory(page: Int, completion: (() -> Void)? = nil) {
        let url = NSURL(string: "https://api.freespoke.com/v2/stories/top/overview?page=\(page)&per_page=2")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if error != nil {
            }
            else {
                do {
                    let json = try JSON(data: data!)
                    
                    if let arrStory = json.array {
                        if !arrStory.isEmpty {
                            self.arrTrendingStory = [TrendingStory]()
                            
                            for story in arrStory {
                                let newStory = TrendingStory(ID: 1,
                                                             url: story["url"].stringValue,
                                                             name: story["name"].stringValue,
                                                             updated_at: story["updated_at"].stringValue,
                                                             sources: story["sources"].intValue,
                                                             bias_left: story["bias_left"].intValue,
                                                             bias_middle: story["bias_middle"].intValue,
                                                             bias_right: story["bias_right"].intValue,
                                                             mainImageUrl: story["main_image"]["url"].stringValue,
                                                             mainImageAttribution: story["main_image"]["attribution"].stringValue,
                                                             publisher_icons: story["publisher_icons"].arrayValue)
                                
                                self.arrTrendingStory.append(newStory)// .append(contentsOf: [newStory])
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.collectionViewTrendingNews.reloadData()
                        }
                    }
                }
                catch {
                    print("error")
                }
            }
        }
        dataTask.resume()
    }
    
    private func getShopppingCollection(page: Int, completion: (() -> Void)? = nil) {
        self.networkManager.getShoppingCollection(page: page,
                                                  perPage: 4,
                                                  completion: { [weak self] shoppingCollectionModel, error in
            guard let self = self else { return }
            if let shoppingCollectionModel = shoppingCollectionModel {
                if !shoppingCollectionModel.collections.isEmpty {
                    self.arrShoppingCollection = shoppingCollectionModel.collections
                }
                
                DispatchQueue.main.async {
                    self.collectionViewShopUsa.reloadData()
                }
            }
        })
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnSearch(_ sender: Any) {
        AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                          action: AnalyticsManager.MatomoAction.appHomeSearch.rawValue,
                                          name: AnalyticsManager.MatomoName.search)
        
        delegate?.didPressSearch()
    }
    
    @IBAction func btnFreespokeWayUp(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeFreespoke.rawValue + text,
                                              name: AnalyticsManager.MatomoName.clickName)
        }
        
        delegate?.showURL(url: urlSearch)
    }
    
    @IBAction func btnFreespokeWayMiddle(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeFreespoke.rawValue + text,
                                              name: AnalyticsManager.MatomoName.clickName)
        }
        
        delegate?.showURL(url: urlShopping)
    }
    
    @IBAction func btnFreespokeWayDown(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeFreespoke.rawValue + text,
                                              name: AnalyticsManager.MatomoName.clickName)
        }
        
        delegate?.showURL(url: urlTrending)
    }
    
    @IBAction func btnBookmarks(_ sender: Any) {
        delegate?.didPressBookmarks()
    }
    
    @IBAction func btnTrendingNews(_ sender: Any) {
        //pageTrending = pageTrending + 1
        //getTrendngStory(page: pageTrending)
        AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                          action: AnalyticsManager.MatomoAction.appHomeTrendingNewsStoryViewMoreClick.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        
        delegate?.showURL(url: "https://freespoke.com/news/what-is-hot")
    }
    
    @IBAction func btnRecentlyViewed(_ sender: Any) {
        delegate?.didPressRecentlyViewed()
    }
    
    @IBAction func btnShopUsa(_ sender: Any) {
        //pageShoppping = pageShoppping + 1
        //getShopppingCollection(page: pageShoppping)
        AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                          action: AnalyticsManager.MatomoAction.appHomeShopUsaViewMoreClick.rawValue,
                                          name: AnalyticsManager.MatomoName.clickName)
        
        delegate?.showURL(url: "https://freespoke.com/shop")
    }
}

extension FreespokeHomepage: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case collectionViewBookmarks:
            if arrBookmarks.isEmpty {
                constBookmarksHeight.constant = 0
            }
            else {
                constBookmarksHeight.constant = 195
            }
            
            return arrBookmarks.count
            
        case collectionViewTrendingNews:
            if arrTrendingStory.isEmpty {
                constViewTrendingNewsHeight.constant = 0
            }
            else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    constViewTrendingNewsHeight.constant = 462
                } else {
                    constViewTrendingNewsHeight.constant = 766
                }
            }
            
            return arrTrendingStory.count
            
        case collectionViewRecentlyViewd:
            if arrRecenlyViewed.isEmpty {
                constRecentlyViewedHeight.constant = 0
            }
            else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    constRecentlyViewedHeight.constant = 200
                } else {
                    if arrRecenlyViewed.count > 4 {
                        constRecentlyViewedHeight.constant = 286
                    }
                    else {
                        constRecentlyViewedHeight.constant = 200
                    }
                }
            }
            
            return arrRecenlyViewed.count
            
        case collectionViewShopUsa:
            if arrShoppingCollection.isEmpty {
                constShopUsaHeight.constant = 0
            }
            else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    constShopUsaHeight.constant = 340
                } else {
                    constShopUsaHeight.constant = 556
                }
            }
            
            return arrShoppingCollection.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case collectionViewBookmarks:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookmarkCellIdentifier", for: indexPath) as? BookmarkCollectionViewCell {
                
                let bookmark = arrBookmarks[indexPath.row]
                
                let url = URL(string: "http://www.google.com/s2/favicons?sz=\(32)&domain=\(bookmark.tileURL.absoluteString)")
                
                //let url = URL(string: "https://t2.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://freespoke-support.freshdesk.com/support/tickets/new&size=32")
                
                cell.imgView.kf.setImage(with: url)
                
                if cell.imgView.image == nil {
                    if bookmark.url == "https://freespoke-support.freshdesk.com/support/tickets/new" {
                        cell.imgView.image = UIImage(named: "Freespoke Torch - Light Mode")
                    }
                }
                
                cell.lblTitle.text = bookmark.title
                
                return cell
            }
            
        case collectionViewTrendingNews:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingNewsCellIdentifier", for: indexPath) as? TrendingNewsCollectionViewCell {
                
                if indexPath.row < self.arrTrendingStory.count {
                    
                    
                    let story = self.arrTrendingStory[indexPath.row]
                    
                    cell.lblTitle.text = story.name
                    
                    //|     Set main image
                    let url = URL(string: story.mainImageUrl)
                    cell.imgView.kf.setImage(with: url)
                    
                    //|     Set Source view elements
                    cell.lblSources.text = "SOURCES: \(story.sources)"
                    cell.lblLeft.text = "LEFT: (\(story.bias_left))"
                    cell.lblMiddle.text = "MIDDLE: (\(story.bias_middle))"
                    cell.lblRight.text = "RIGHT (\(story.bias_right))"
                    
                    //|     Set updated date
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    
                    if let date = dateFormatter.date(from: story.updated_at) {
                        if let days = Date().days(sinceDate: date) {
                            switch days {
                            case 0:
                                cell.lblUpdated.text = "Updated: Today"
                                
                            case 1:
                                cell.lblUpdated.text = "Updated: \(days) Day Ago"
                                
                            default:
                                cell.lblUpdated.text = "Updated: \(days) Days Ago"
                            }
                        }
                    }
                    
                    //|     Set image atribution button
                    let attributeString = NSMutableAttributedString(
                        string: "photo: " + story.mainImageAttribution,
                        attributes: yourAttributes
                    )
                    
                    cell.btnPhoto.setAttributedTitle(attributeString, for: .normal)
                    
                    //|     Set pubishers logo images
                    switch story.publisher_icons.count {
                    case 0:
                        cell.imgPublisherFirst.isHidden = true
                        cell.imgPublisherSecond.isHidden = true
                        cell.viewPublisher.isHidden = true
                        
                    case 1:
                        if let image = story.publisher_icons[0].string {
                            if let url = URL(string: image) {
                                cell.imgPublisherFirst.kf.setImage(with: url)
                            }
                        }
                        
                        cell.imgPublisherSecond.isHidden = true
                        cell.viewPublisher.isHidden = true
                        
                    case 2:
                        if let image = story.publisher_icons[0].string {
                            if let url = URL(string: image) {
                                cell.imgPublisherFirst.kf.setImage(with: url)
                            }
                        }
                        
                        if let image = story.publisher_icons[1].string {
                            if let url = URL(string: image) {
                                cell.imgPublisherSecond.kf.setImage(with: url)
                            }
                        }
                        
                        cell.viewPublisher.isHidden = true
                        
                    default:
                        if let image = story.publisher_icons[0].string {
                            if let url = URL(string: image) {
                                cell.imgPublisherFirst.kf.setImage(with: url)
                            }
                        }
                        
                        if let image = story.publisher_icons[1].string {
                            if let url = URL(string: image) {
                                cell.imgPublisherSecond.kf.setImage(with: url)
                            }
                        }
                        
                        cell.lblPublisher.text = "+\(story.publisher_icons.count - 2)"
                    }
                    
                    cell.delegate = self
                    cell.indexPath = indexPath
                }
                
                return cell
            }
            
        case collectionViewRecentlyViewd:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentlyViewedCellIdentifier", for: indexPath) as? RecentlyViewedCollectionViewCell,
               indexPath.row < self.arrRecenlyViewed.count {
                let bookmark = self.arrRecenlyViewed[indexPath.row]
                if let strUrl = bookmark.urlString {
                    let url = URL(string: "http://www.google.com/s2/favicons?sz=\(32)&domain=\(strUrl)")
                    cell.imgView.kf.setImage(with: url)
                }
                cell.lblTitle.text = bookmark.displayTitle
                return cell
            }
            
        case collectionViewShopUsa:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shopUsaCellIdentifier", for: indexPath) as? ShopUsaCollectionViewCell,
               indexPath.row < self.arrShoppingCollection.count {
                let shop = arrShoppingCollection[indexPath.row]
                cell.lblTitle.text = shop.title
                let url = URL(string: shop.thumbnail)
                cell.imgView.kf.setImage(with: url)
                return cell
            }
            
        default:
            break
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookmarkCellIdentifier", for: indexPath) as! BookmarkCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case collectionViewBookmarks:
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeBookmarks.rawValue,
                                              name: AnalyticsManager.MatomoName.clickName)
            
            let site = arrBookmarks[indexPath.row]
            
            delegate?.showURL(url: site.url)
            
        case collectionViewTrendingNews:
            guard indexPath.row < self.arrTrendingStory.count else { return }
            let story = self.arrTrendingStory[indexPath.row]
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeTrendingNewsStoryClick.rawValue,
                                              name: story.name,
                                              url: story.url.asURL)
            
            delegate?.showURL(url: story.url)
            
        case collectionViewRecentlyViewd:
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeRecently.rawValue,
                                              name: AnalyticsManager.MatomoName.clickName)
            guard indexPath.row < self.arrRecenlyViewed.count else { return }
            let site = self.arrRecenlyViewed[indexPath.row]
            if let url = site.urlString {
                delegate?.showURL(url: url)
            }
            
        case collectionViewShopUsa:
            guard indexPath.row < self.arrShoppingCollection.count else { return }
            let shop = arrShoppingCollection[indexPath.row]
            
            AnalyticsManager.trackMatomoEvent(category: .appHomeCategory,
                                              action: AnalyticsManager.MatomoAction.appHomeShopUsaClick.rawValue,
                                              name: shop.title,
                                              url: shop.url.asURL)
            
            delegate?.showURL(url: shop.url)
            
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView {
        case collectionViewBookmarks:
            return CGSize(width: 81, height: 77)
            
        case collectionViewTrendingNews:
            var noOfCellsInRow = 1
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                noOfCellsInRow = 2
            } else {
                noOfCellsInRow = 1
            }
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
            
            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            return CGSize(width: size, height: 296)
            
        case collectionViewRecentlyViewd:
            return CGSize(width: 81, height: 77)
            
        case collectionViewShopUsa:
            var noOfCellsInRow = 2
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                noOfCellsInRow = 4
            } else {
                noOfCellsInRow = 2
            }
            
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
            
            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            return CGSize(width: size, height: 213)
            
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}

extension FreespokeHomepage: TrendingNewsCollectionViewCellDelegate {
    func didBtnPhoto(indexPath: IndexPath) {
        guard indexPath.row < self.arrTrendingStory.count else { return }
        let story = self.arrTrendingStory[indexPath.row]
        
        var image = story.mainImageAttribution
        
        if !image.contains("https://") {
            image = "https://" + image
        }
        
        delegate?.showURL(url: image)
    }
    
    func didBtnViewSummary(indexPath: IndexPath) {
        guard indexPath.row < self.arrTrendingStory.count else { return }
        let story = arrTrendingStory[indexPath.row]
        
        delegate?.showURL(url: story.url)
    }
}

class TrendingStory: Equatable, Hashable {
    var ID: Int
    var url: String
    var name: String
    var updated_at: String
    var sources: Int
    var bias_left: Int
    var bias_middle: Int
    var bias_right: Int
    var mainImageUrl: String
    var mainImageAttribution: String
    var publisher_icons: [JSON]
    
    init(ID: Int, url: String, name: String, updated_at: String, sources: Int, bias_left: Int, bias_middle: Int, bias_right: Int, mainImageUrl: String, mainImageAttribution: String, publisher_icons: [JSON]) {
        self.ID = ID
        self.url = url
        self.name = name
        self.updated_at = updated_at
        self.sources = sources
        self.bias_left = bias_left
        self.bias_middle = bias_middle
        self.bias_right = bias_right
        self.mainImageUrl = mainImageUrl
        self.mainImageAttribution = mainImageAttribution
        self.publisher_icons = publisher_icons
    }
    
    var hashValue: Int {
        get {
            return ID.hashValue << 15 + name.hashValue
        }
    }
}

func ==(lhs: TrendingStory, rhs: TrendingStory) -> Bool {
    return lhs.url == rhs.url
}

extension UIView {
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension Date {
    func days(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
    }
}
