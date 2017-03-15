//
//  ViewController.swift
//  SutaPageViewDemo
//
//  Created by Suta on 2017/3/14.
//  Copyright © 2017年 Suta. All rights reserved.
//

import UIKit
import SutaPageView

class ViewController: UIViewController, SutaPageViewDelegate {
    
    var pageView: SutaPageView!
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        var controllers = [UIViewController]()
        for _ in 0 ..< 4 {
            let controller = UIViewController()
            controller.view.backgroundColor = UIColor(red: CGFloat(arc4random() % 256) / 255, green: CGFloat(arc4random() % 256) / 255, blue: CGFloat(arc4random() % 256) / 255, alpha: 1)
            controllers.append(controller)
        }
        pageView = SutaPageView(controllers: controllers)
        pageView.delegate = self
        view.addSubview(pageView)
        pageView.translatesAutoresizingMaskIntoConstraints = false
        let pageViewFirstConstraintArray = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["pageView" : pageView])
        let pageViewSecondConstraintArray = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["pageView" : pageView])
        view.addConstraints(pageViewFirstConstraintArray)
        view.addConstraints(pageViewSecondConstraintArray)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let controller = UIViewController()
            controller.view.backgroundColor = UIColor(red: CGFloat(arc4random() % 256) / 255, green: CGFloat(arc4random() % 256) / 255, blue: CGFloat(arc4random() % 256) / 255, alpha: 1)
            self.pageView.insertController(controller, atIndex: 1, animated: true)
        }
        
    }
    
    // MARK: - SutaPageViewDelegate
    
    func pageView(_ pageView: SutaPageView, shouldSelect controller: UIViewController) -> Bool {
        return true
    }
    
    func pageView(_ pageView: SutaPageView, didSelect controller: UIViewController) {
        print("PageView didSelect \(controller), index \(pageView.controllers.index(of: controller))")
    }

}

