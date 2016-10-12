//
//  ContainerViewController.swift
//  SnapchatSwipeView
//
//  Created by Jake Spracher on 8/9/15.
//  Copyright (c) 2015 Jake Spracher. All rights reserved.
//

import UIKit

protocol SnapContainerViewControllerDelegate {
    func innerScrollViewShouldScroll() -> Bool
}

class SnapContainerViewController: UIViewController {
    
    var leftVc: UIViewController!
    var middleVc: UIViewController!
    var rightVc: UIViewController!
    var topVc: UIViewController!
    
    var initialContentOffset = CGPoint() // scrollView initial offset
    var middleVertScrollVc: VerticalScrollViewController!
    var scrollView: UIScrollView!
    var delegate: SnapContainerViewControllerDelegate?
    
    class func containerViewWith(_ leftVC: UIViewController, middleVC: UIViewController, rightVC: UIViewController, topVC: UIViewController) -> SnapContainerViewController {
        let container = SnapContainerViewController()
        container.leftVc = leftVC
        container.middleVc = middleVC
        container.rightVc = rightVC
        container.topVc = topVC
        return container
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVerticalScrollView()
        setupHorizontalScrollView()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
    
    func setupVerticalScrollView() {
        middleVertScrollVc = VerticalScrollViewController.verticalScrollVcWith(middleVc, topVc: topVc)
        delegate = middleVertScrollVc
    }
    
    func setupHorizontalScrollView() {
        
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        
        scrollView.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(scrollView)
        
        let scrollWidth: CGFloat  = 3 * view.bounds.width
        let scrollHeight: CGFloat  = view.bounds.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        
        leftVc.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        middleVertScrollVc.view.frame = CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        rightVc.view.frame = CGRect(x: 2 * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        addChildViewController(leftVc)
        scrollView.addSubview(leftVc.view)
        leftVc.didMove(toParentViewController: self)
        
        addChildViewController(middleVertScrollVc)
        scrollView.addSubview(middleVertScrollVc.view)
        middleVertScrollVc.didMove(toParentViewController: self)
        
        addChildViewController(rightVc)
        scrollView.addSubview(rightVc.view)
        scrollView.sendSubview(toBack: rightVc.view)
        rightVc.didMove(toParentViewController: self)
        
        scrollView.contentOffset.x = middleVertScrollVc.view.frame.origin.x
        scrollView.delegate = self;
    }
    
}

// MARK: UIScrollView Delegate

extension SnapContainerViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if delegate != nil && !delegate!.innerScrollViewShouldScroll() {
            // This is probably crazy movement: diagonal scrolling
            var newOffset = CGPoint()
            
            if (abs(scrollView.contentOffset.x) > abs(scrollView.contentOffset.y)) {
                newOffset = CGPoint(x: initialContentOffset.x, y: initialContentOffset.y)
            } else {
                newOffset = CGPoint(x: initialContentOffset.x, y: initialContentOffset.y)
            }
            
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
            scrollView.setContentOffset(newOffset,animated:  false)
        }
    }
}
