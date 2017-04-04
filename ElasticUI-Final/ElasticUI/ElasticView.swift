//
//  ElasticView.swift
//  ElasticUI
//
//  Created by I_MT on 2017/4/4.
//  Copyright © 2017年 Daniel Tavares. All rights reserved.
//

import UIKit

class ElasticView: UIView {

    fileprivate let topControlPointView = UIView()
    fileprivate let leftControlPointView = UIView()
    fileprivate let bottomControlPointView = UIView()
    fileprivate let rightControlPointView = UIView()
    
    private let elasticShape = CAShapeLayer()
    
    private lazy var displayLink:CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateLoop))
        displayLink.add(to:RunLoop.current, forMode:.commonModes )
        return displayLink
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponents()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupComponents()
    }
    
    private func setupComponents() {
        let bgColor = backgroundColor
        backgroundColor = UIColor.clear
        elasticShape.fillColor = bgColor?.cgColor
        elasticShape.path = UIBezierPath(rect: self.bounds).cgPath
        layer.addSublayer(elasticShape)
        
        
        
        
        for controlPoint  in [topControlPointView,leftControlPointView,bottomControlPointView,rightControlPointView] {
            addSubview(controlPoint)
            controlPoint.frame = CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0)
            controlPoint.backgroundColor = UIColor.blue
            //controlPoint.backgroundColor = UIColor.clear
        }
        
        positionControlPoints()
    }
    
    fileprivate func positionControlPoints(){
        
        topControlPointView.center = CGPoint.init(x: bounds.midX, y: 0.0)
        leftControlPointView.center = CGPoint.init(x: 0.0, y: bounds.midY)
        bottomControlPointView.center = CGPoint.init(x: bounds.midX, y: bounds.maxY)
        rightControlPointView.center = CGPoint.init(x: bounds.maxX, y: bounds.midY)
        
    }
    
    private func bezierPathForControlPoints()->CGPath{
        //1 
        let path = UIBezierPath()
        
        //2
        let top = topControlPointView.layer.presentation()?.position
        let left = leftControlPointView.layer.presentation()?.position
        let bottom = bottomControlPointView.layer.presentation()?.position
        let right = rightControlPointView.layer.presentation()?.position
        
        let width = frame.size.width
        let height = frame.size.height
        
        //3
        path.move(to:CGPoint.init(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint.init(x: width, y: 0), controlPoint: top!)
        path.addQuadCurve(to: CGPoint.init(x: width, y: height), controlPoint: right!)
        path.addQuadCurve(to: CGPoint.init(x: 0, y: height), controlPoint: bottom!)
        path.addQuadCurve(to: CGPoint.init(x: 0, y: 0), controlPoint: left!)
        
        //4
        return path.cgPath
    }
    
    
    func updateLoop(){
        elasticShape.path = bezierPathForControlPoints()
    }
    
    fileprivate func startUpdateLoop(){
        displayLink.isPaused = false
    }
    fileprivate func stopUpdateLoop(){
        displayLink.isPaused = true
    }
  
    @IBInspectable   var overshootAmount:CGFloat = 10
    
    override var backgroundColor: UIColor?{
        willSet{
            if let newValue = newValue{
                elasticShape.fillColor = newValue.cgColor
                super.backgroundColor = UIColor.clear
            }
        }
    }
    
}

extension ElasticView {
    fileprivate func animateControlPoints(){
        //1
        let overshootAmount = self.overshootAmount
        //2
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: UIViewAnimationOptions.curveLinear, animations: {
            //3
            self.topControlPointView.center.y -= overshootAmount
            self.leftControlPointView.center.x -= overshootAmount
            self.bottomControlPointView.center.y += overshootAmount
            self.rightControlPointView.center.x += overshootAmount
        }) { (_) in
            //4
            UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 5.5, options: .curveLinear, animations: {
                //5
                self.positionControlPoints()
            }, completion: { (_) in
                //6
                self.stopUpdateLoop()
            })
        }
    
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.startUpdateLoop()
        animateControlPoints()
    }
}
