//
//  SutaPageView.swift
//  SutaPageView
//
//  Created by Suta on 2017/3/7.
//  Copyright © 2017年 Suta. All rights reserved.
//

import UIKit

@objc public protocol SutaPageViewDelegate {
    @objc optional func pageView(_ pageView: SutaPageView, didSelect controller: UIViewController)
    @objc optional func pageView(_ pageView: SutaPageView, shouldSelect controller: UIViewController) -> Bool
}

public class SutaPageView: UIView, UIScrollViewDelegate {
    
    public private(set) var controllers = [UIViewController]() {
        didSet {
            didSetControllers(oldValue)
        }
    }
    public var page = 0 {
        didSet {
            guard page >= 0 && page < controllers.count else {
                page = oldValue
                return
            }
            if let shouldSelect = delegate?.pageView?(self, shouldSelect: controllers[page]), !shouldSelect {
                page = oldValue
                return
            }
            didSetPage(oldValue)
        }
    }
    public weak var delegate: SutaPageViewDelegate?
    var scrollView: UIScrollView!
    var scrollContainerView: UIView!
    var scrollContainerViewWidthConstraint: NSLayoutConstraint?
    var setPageBySelf = false
    var shouldResetPage = false
    var currentPage = 0
    
    // MARK: -
    
    deinit {
        removeObserver()
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        configure()
        buildUI()
    }
    
    convenience public init(controllers: [UIViewController]) {
        self.init()
        defer {
            self.controllers = controllers
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        buildUI()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let myController = myController() {
            if myController.automaticallyAdjustsScrollViewInsets {
                myController.automaticallyAdjustsScrollViewInsets = false
            }
        }
        setupControllers()
        if shouldResetPage {
            shouldResetPage = false
            page = Int(page)
        }
    }
    
    // MARK: - Public
    
    public func setPage(_ newPage: Int, animated: Bool = false) {
        guard newPage >= 0 && newPage < controllers.count else {
            return
        }
        if let shouldSelect = delegate?.pageView?(self, shouldSelect: controllers[newPage]), !shouldSelect {
            return
        }
        setPageBySelf = true
        page = newPage
        let scrollViewContentOffsetX = CGFloat(page) * scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: scrollViewContentOffsetX, y: scrollView.contentOffset.y) , animated: animated)
    }
    
    public func resetControllers(_ controllers: [UIViewController]) {
        self.controllers = controllers
    }
    
    // MARK: - Private
    
    func configure() {
        addObserver()
    }
    
    func buildUI() {
        
        guard scrollContainerViewWidthConstraint == nil else {
            return
        }
        
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        addSubview(scrollView);
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let scrollViewFirstConstraintArray = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scrollView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView" : scrollView])
        let scrollViewSecondConstraintArray = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[scrollView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView" : scrollView])
        addConstraints(scrollViewFirstConstraintArray)
        addConstraints(scrollViewSecondConstraintArray)
        
        scrollContainerView = UIView()
        scrollView.addSubview(scrollContainerView)
        scrollContainerView.translatesAutoresizingMaskIntoConstraints = false
        let scrollContainerViewFirstConstraint = NSLayoutConstraint(item: scrollContainerView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        let scrollContainerViewSecondConstraint = NSLayoutConstraint(item: scrollContainerView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        let scrollContainerViewThirdConstraint = NSLayoutConstraint(item: scrollContainerView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        let scrollContainerViewFourthConstraint = NSLayoutConstraint(item: scrollContainerView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0)
        let scrollContainerViewFifthConstraint = NSLayoutConstraint(item: scrollContainerView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0)
        scrollContainerViewWidthConstraint = NSLayoutConstraint(item: scrollContainerView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: CGFloat(3), constant: 0)
        scrollView.addConstraint(scrollContainerViewFirstConstraint)
        scrollView.addConstraint(scrollContainerViewSecondConstraint)
        scrollView.addConstraint(scrollContainerViewThirdConstraint)
        scrollView.addConstraint(scrollContainerViewFourthConstraint)
        scrollView.addConstraint(scrollContainerViewFifthConstraint)
        scrollView.addConstraint(scrollContainerViewWidthConstraint!)
        
    }
    
    func myController() -> UIViewController? {
        var controller: UIViewController?
        var responder = next
        while responder != nil {
            if responder! is UIViewController {
                controller = responder as? UIViewController
                break
            }
            responder = responder?.next
        }
        return controller
    }
    
    func setupControllers() {
        guard controllers.count > 0 && scrollContainerView.subviews.count == 0 else {
            return
        }
        if let myController = myController() {
            for (index, controller) in controllers.enumerated() {
                myController.addChildViewController(controller)
                scrollContainerView.addSubview(controller.view)
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                let controllerViewFirstConstraint = NSLayoutConstraint(item: controller.view, attribute: .top, relatedBy: .equal, toItem: controller.view.superview, attribute: .top, multiplier: 1, constant: 0)
                let controllerViewSecondConstraint = NSLayoutConstraint(item: controller.view, attribute: .bottom, relatedBy: .equal, toItem: controller.view.superview, attribute: .bottom, multiplier: 1, constant: 0)
                let controllerViewThirdConstraint = NSLayoutConstraint(item: controller.view, attribute: .width, relatedBy: .equal, toItem: controller.view.superview, attribute: .width, multiplier: 1 / CGFloat(controllers.count > 0 ? controllers.count : 1), constant: 0)
                var controllerViewFourthConstraint: NSLayoutConstraint?
                if index == 0 {
                    controllerViewFourthConstraint = NSLayoutConstraint(item: controller.view, attribute: .leading, relatedBy: .equal, toItem: controller.view.superview, attribute: .leading, multiplier: 1, constant: 0)
                } else {
                    let previousController = controllers[index - 1]
                    controllerViewFourthConstraint = NSLayoutConstraint(item: controller.view, attribute: .leading, relatedBy: .equal, toItem: previousController.view, attribute: .trailing, multiplier: 1, constant: 0)
                }
                scrollContainerView.addConstraint(controllerViewFirstConstraint)
                scrollContainerView.addConstraint(controllerViewSecondConstraint)
                scrollContainerView.addConstraint(controllerViewThirdConstraint)
                if let constaint = controllerViewFourthConstraint {
                    scrollContainerView.addConstraint(constaint)
                }
            }
        }
    }
    
    // MARK: - Observe
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(SutaPageView.handleApplicationWillChangeStatusBarOrientation(_:)), name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleApplicationWillChangeStatusBarOrientation(_ sender: Notification) {
        shouldResetPage = true
    }
    
    // MARK: - getter & setter
    
    func didSetControllers(_ oldValue: [UIViewController]) {
        
        for oldController in oldValue {
            if let oldControllerViewSuperview = oldController.view.superview {
                if oldControllerViewSuperview.isEqual(scrollContainerView) {
                    oldController.view.removeFromSuperview()
                    oldController.removeFromParentViewController()
                }
            }
        }
        
        if scrollContainerViewWidthConstraint != nil {
            scrollView.removeConstraint(scrollContainerViewWidthConstraint!)
        }
        
        scrollContainerViewWidthConstraint = NSLayoutConstraint(item: scrollContainerView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: CGFloat(controllers.count > 0 ? controllers.count : 1), constant: 0)
        scrollView.addConstraint(scrollContainerViewWidthConstraint!)
        
        setupControllers()
        
    }
    
    func didSetPage(_ oldValue: Int) {
        if (setPageBySelf) {
            setPageBySelf = false
        } else {
            setPage(page)
        }
        if (page != oldValue) {
            delegate?.pageView?(self, didSelect: controllers[page])
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width + 10
        currentPage = Int(floor(Double((scrollView.contentOffset.x - pageWidth / 2) / pageWidth))) + 1
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = scrollView.frame.width + 10
        var newPage: Int = 0
        if velocity.x == 0 {
            newPage = Int(floor((Double(targetContentOffset.pointee.x) - Double(pageWidth) / 2) / Double(pageWidth))) + 1
        } else {
            newPage = velocity.x > 0 ? currentPage + 1 : currentPage - 1
            newPage = max(0, newPage)
            newPage = min(controllers.count - 1, newPage)
            if CGFloat(newPage) > scrollView.contentSize.width / pageWidth {
                newPage = (Int)(ceil(Double(scrollView.contentSize.width / pageWidth)) - 1)
            }
        }
        
        if let shouldSelect = delegate?.pageView?(self, shouldSelect: controllers[newPage]), !shouldSelect {
            targetContentOffset.pointee = CGPoint(x: CGFloat(page) * pageWidth, y: targetContentOffset.pointee.y)
        } else {
            targetContentOffset.pointee = CGPoint(x: CGFloat(newPage) * pageWidth, y: targetContentOffset.pointee.y)
        }
        setPageBySelf = true
        page = newPage
        
    }

}
