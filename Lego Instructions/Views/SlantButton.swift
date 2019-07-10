//
//  SlantButton.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 3/15/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation
import UIKit

class SlantButton: UIButton {
    
    var slantLength: CGFloat = 0 {
        didSet {
            updatePath()
        }
    }
    
    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 0
        shapeLayer.fillColor = UIColor.white.cgColor
        return shapeLayer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updatePath() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX - slantLength, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX , y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX + slantLength , y: bounds.minY))
        path.close()
        shapeLayer.path = path.cgPath
        layer.mask = shapeLayer
    }

}

