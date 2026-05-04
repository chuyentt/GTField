//
//  ModelController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The model or data source for PhotosViewController.
 */

import UIKit

@objc(ModelController)
class ModelController: NSObject, UIPageViewControllerDataSource {
    
    var pageData: [PhotoAnnotation] = []
    var currentPageIndex: Int
    var dataViewController: DataViewController?
    
    /*
    A controller object that manages a simple model -- a collection of map annotations
    
    The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
    It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
    
    There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
    */
    
    override init() {
        currentPageIndex = 0
        super.init()
    }
    
    // Bắt đầu view từ map
    // Slide 3 >> 1->2
    // << Slide back 3
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // return the data view controller for the given index
        if index >= self.pageData.count {
            return nil
        }
        
        // vreate a new view controller and pass suitable data
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController")
            as! DataViewController
        dataViewController.dataObject = self.pageData[index]
        
        self.dataViewController = dataViewController
        return dataViewController
    }
    
    // Slide 2 >> 1->2
    // << Slide back 2
    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the
        // view controller stores the model object; you can therefore use the model object to identify the index.
        //
        if viewController.dataObject == nil {
            return NSNotFound
        }   //This may never happen?
        return self.pageData.firstIndex(of: viewController.dataObject!)!
    }
    
    
    //#MARK: - UIPageViewControllerDataSource
    // << Slide back 1 1 <- 2
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let photosViewController = pageViewController.delegate as! PhotosViewController?
        
        if !(photosViewController?.pageAnimationFinished ?? false) {
            // we are still animating don't return a previous view controller too soon
            return nil
        }
        
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == 0 || index == NSNotFound {
            // we are at the first page, don't go back any further
            return nil
        }
        
        index -= 1
        currentPageIndex = index
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    // Slide 1 >> 1->2
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let photosViewController = pageViewController.delegate as! PhotosViewController?
        
        if !(photosViewController?.pageAnimationFinished ?? false) {
            // we are still animating don't return a next view controller too soon
            return nil
        }
        
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == self.pageData.count-1 || index == NSNotFound {
            // we are at the last page, don't go back any further
            // kiểm tra thêm điều kiện index == self.pageData.count-1 để khỏi bị bug
            return nil
        }
        
        index += 1
        currentPageIndex = index
        
        // Dừng lại nếu cuối trang hoặc 1 ảnh
        if index == self.pageData.count {
            return nil
        }
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}
