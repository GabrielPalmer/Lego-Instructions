//
//  InstructionsViewController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import PDFKit

class InstructionsViewController: UIViewController, PDFViewDelegate {
    
    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var displayView: UIView!
    
    @IBOutlet weak var tabsStackView: UIStackView!
    var tabButtons: [UIButton] = []
    
    var pdfView: PDFView?
    
    var pdfURLs: [String] = []
    var selectedTab: Int = 0
    
    var legoSet: LegoSet? {
        didSet {
            guard let legoSet = legoSet else { return }
            setNameLabel.text = legoSet.name
            
            PDFController.shared.fetchInstructionURLs(for: legoSet) { (instructions) in
                DispatchQueue.main.async {
                    self.pdfURLs = instructions
                    self.setUpTabsStackView()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if legoSet == nil {
            setNameLabel.text = "No Set Selected"
            activityLabel.isHidden = false
        } else {
            activityLabel.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func setUpTabsStackView() {
        
        tabsStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        //tab bar won't display if there is only one page
        if pdfURLs.count < 2 {
            tabsStackView.isHidden = true
            return
        } else {
            tabsStackView.isHidden = false
        }
        
        let screenWidth = view.bounds.width
        var shouldShortenTabs = false
        
        let estimatedButtonWidth = (screenWidth / CGFloat(integerLiteral: pdfURLs.count)) - 3.0
        if estimatedButtonWidth <= 100.0 {
            shouldShortenTabs = true
        }
        
        for tabIndex in 0...pdfURLs.count - 1 {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: estimatedButtonWidth, height: 60))
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            
            button.tag = tabIndex
            button.titleLabel?.font = UIFont(name: "tabButton", size: 23.0)
            button.backgroundColor = #colorLiteral(red: 0.8176259082, green: 0.822451515, blue: 0.8597715736, alpha: 1)
            button.titleLabel?.textColor = UIColor.black
            
            
            if shouldShortenTabs {
                button.setTitle("\(tabIndex + 1)", for: .normal)
            } else {
                button.setTitle("Part \(tabIndex + 1)", for: .normal)
            }
            
            tabsStackView.addArrangedSubview(button)
        }
        
        switchToTab(0)
        
    }
    
    func switchToTab(_ tab: Int) {
        for button in tabsStackView.arrangedSubviews {
            if tab != button.tag {
                button.backgroundColor = #colorLiteral(red: 0.8176259082, green: 0.822451515, blue: 0.8597715736, alpha: 1)
            } else {
                button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
        }
        
        if pdfView == nil {
            
            let newPDFView = PDFView()
            newPDFView.delegate = self
            newPDFView.translatesAutoresizingMaskIntoConstraints = false
            newPDFView.addSubview(pdfView!)
            
            NSLayoutConstraint.activate([
                newPDFView.leadingAnchor.constraint(equalTo: displayView.leadingAnchor),
                newPDFView.trailingAnchor.constraint(equalTo: displayView.trailingAnchor),
                newPDFView.topAnchor.constraint(equalTo: displayView.topAnchor),
                newPDFView.bottomAnchor.constraint(equalTo: displayView.bottomAnchor),
                ])
            
            pdfView = newPDFView
        }
        
        activityLabel.text = "Loading Instructions for part \(tab + 1)"
        activityLabel.isHidden = false
        
        DispatchQueue.global(qos: .utility).async {
            let document = PDFDocument(url: URL(string: self.pdfURLs[tab])!)
            DispatchQueue.main.async {
                self.activityLabel.isHidden = true
                self.pdfView?.document = document
            }
        }
        
    }
    
    @objc func tabButtonTapped(_ sender: UIButton) {
        switchToTab(sender.tag)
        
    }
    
}
