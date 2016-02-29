//
//  ViewController.swift
//  UnlimitedScroll
//
//  Created by 邓金龙 on 16/2/29.
//  Copyright © 2016年 邓金龙. All rights reserved.
//

import UIKit

let IMAGEVIEWTAG = 100
let SCREENWIDTH = UIScreen.mainScreen().bounds.width

protocol ViewControllerDelegate:NSObjectProtocol{
    func selectIndex(index:Int);
}

class ViewController: UIViewController {

    //MARK:- 属性
    var imageArray = ["1","2","3","4"]
    //当前显示的索引
    var currentIndex = 1
    //委托对象
    weak var delegate:ViewControllerDelegate?
    
    private var timer:NSTimer!
    //MARK:- 懒加载
    //滚动视图
    private lazy var scrollerView: UIScrollView = {
        var sc = UIScrollView(frame: CGRect(x: 0, y: 20, width: SCREENWIDTH, height: 200))
        sc.pagingEnabled = true
        sc.bounces = false
        sc.delegate = self
        return sc
    }()
    private lazy var pageControl: UIPageControl = {
        var page = UIPageControl()
        page.currentPageIndicatorTintColor = UIColor.whiteColor()
        page.pageIndicatorTintColor = UIColor.grayColor()
        return page

    }()
    private lazy var tapGes:UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: "tapAction")
        return tap
    }()
    //MARK:- 定时器方法
    func scrollAction(){
        //由于刚开启定时器是，会立刻调用，这样可以暂停一段时间，效果更好
        let lastPoint = scrollerView.contentOffset
        scrollerView.setContentOffset(CGPoint(x: lastPoint.x + SCREENWIDTH, y: 0.0), animated: true)
    }
    func tapAction(){
        //拖过委托，将选中的下标传出
        if (delegate != nil) {
            delegate?.selectIndex(currentIndex)
        }
        print(currentIndex)
    }
    //MARK:-加载视图
    override func loadView() {
        super.loadView()
        //滚动视图
        scrollerView.contentSize = CGSize(width: SCREENWIDTH * 3.0, height: 200)
        scrollerView.setContentOffset(CGPoint(x: SCREENWIDTH, y: 0) , animated: false)
        scrollerView.showsHorizontalScrollIndicator = false
        scrollerView.showsVerticalScrollIndicator = false
        view.addSubview(scrollerView)
        //pageControl
        pageControl.frame = CGRect(x: SCREENWIDTH/2.0 - CGFloat(imageArray.count*15), y: 190.0, width: CGFloat(imageArray.count*30), height: 30.0)
        pageControl.numberOfPages = imageArray.count
        pageControl.currentPage = currentIndex
        view.addSubview(pageControl)
        //创建定时器
        createTimer()
        //创建图片
        creatImageView()
    }
    //MARK:- 创建定时器
    private func createTimer(){
        //定时器
        timer = NSTimer(timeInterval: 2, target: self, selector: "scrollAction", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    //MARK:- 创建图片
    private func creatImageView(){
        for i in 0..<3{
            //创建imageView
            let imageView = createImageView(i)
            imageView.userInteractionEnabled = true
            //添加图片
            loadImage(i, imageView: imageView)
            imageView.tag = IMAGEVIEWTAG+i
            scrollerView.addSubview(imageView)
        }
    }
    //加载图片
    private func loadImage(index:Int,imageView:UIImageView){
        //有于其他视图点击不到，所以不需要点击事件
        imageView.removeGestureRecognizer(tapGes)
        
        if index == 0 {
            imageView.image = UIImage(named: imageArray[getLastIndex(currentIndex)])
        }else if index == 1{
            imageView.image = UIImage(named: imageArray[currentIndex])
            //只有当前显示的视图才需要点击事件
            imageView.addGestureRecognizer(tapGes)
        }else{
            imageView.image = UIImage(named: imageArray[getNextIndex(currentIndex)])
        }
    }
    /**
     创建图片
     */
    private func createImageView(index:Int) -> UIImageView{
        let imageView = UIImageView(frame: CGRect(x: SCREENWIDTH * CGFloat(index), y: 0, width: SCREENWIDTH, height: 200))
        return imageView
    }
    /**
     获取显示图片的上一张图片索引
     */
    private func getLastIndex(index:Int) -> Int{
        if index == 0{
            return imageArray.count-1
        }else{
            return index-1
        }
    }
    /**
     获取显示图片的下一张图片索引
     */
    private func getNextIndex(index:Int) -> Int{
        if index == imageArray.count-1{
            return 0
        }else{
            return index+1
        }
    }
    //MARK:-图片转换
    private func changeImageView(){
        for i in 0..<3{
            let imageView = scrollerView.viewWithTag(IMAGEVIEWTAG+i) as! UIImageView
            loadImage(i, imageView: imageView)
        }
    }
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: UIScrollViewDelegate{
    //改变当前显示的索引
    private func changeIndex(isNext:Bool){
        if isNext {
            if currentIndex == imageArray.count-1{
                currentIndex = 0
            }else{
                currentIndex++
            }
        }else{
            if currentIndex == 0 {
                currentIndex = imageArray.count-1
            }else{
                currentIndex--
            }
        }
    }
    //改变滚动视图的位置
    private func changeScrollView(isNext:Bool) {
        changeIndex(isNext)
        changeImageView()
        scrollerView.setContentOffset(CGPoint(x: SCREENWIDTH, y: 0) , animated: false)
        pageControl.currentPage = currentIndex
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollerView.contentOffset.x > SCREENWIDTH{
            changeScrollView(true)
        }else if scrollerView.contentOffset.x < SCREENWIDTH{
            changeScrollView(false)
        }
    }
    //定时器轮播时会调用该方法
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollerView.contentOffset.x > SCREENWIDTH{
            changeScrollView(true)
        }else if scrollerView.contentOffset.x < SCREENWIDTH{
            changeScrollView(false)
        }    }
    //手动拖拽的时候把定时器暂时关闭
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        timer.invalidate()
        timer = nil
    }
    //拖拽结束时，再开启定时器
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        createTimer()
    }
}

