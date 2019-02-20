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
    
    
    @IBOutlet weak var displayView: UIView!
    var pdfView: PDFView?
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var tabsStackView: UIStackView!
    
    var pdfURLs: [String] = []
    var currentTab: Int = 0
    
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
            activityIndicator.isHidden = true
            setNameLabel.text = "No Set Selected"
            displayView.bringSubviewToFront(activityView)
            activityView.isHidden = false
            
        } else {
            activityView.isHidden = true
        }
    }
    
    
    func setUpTabsStackView() {
        
        //delete previous tabs if loading from search tab again
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
        
        let estimatedButtonWidth = ((screenWidth - 14.0) / CGFloat(integerLiteral: pdfURLs.count)) - tabsStackView.spacing
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
        currentTab = tab
        
        for button in tabsStackView.arrangedSubviews {
            if tab != button.tag {
                button.backgroundColor = #colorLiteral(red: 0.7672145258, green: 0.7784764083, blue: 0.8122620558, alpha: 1)
            } else {
                button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
        }
        
        if pdfView == nil {
            
            let newPDFView = PDFView()
            newPDFView.delegate = self
            self.pdfView?.autoScales = true
            newPDFView.translatesAutoresizingMaskIntoConstraints = false
            displayView.addSubview(newPDFView)
            
            NSLayoutConstraint.activate([
                newPDFView.leadingAnchor.constraint(equalTo: displayView.leadingAnchor, constant: 15.0),
                newPDFView.trailingAnchor.constraint(equalTo: displayView.trailingAnchor, constant: 15.0),
                newPDFView.topAnchor.constraint(equalTo: displayView.topAnchor, constant: 15.0),
                newPDFView.bottomAnchor.constraint(equalTo: displayView.bottomAnchor, constant: 15.0)
                ])
            
            pdfView = newPDFView
        }
        
        activityLabel.text = "Loading Instructions For Part \(tab + 1)"
        activityIndicator.isHidden = false
        displayView.bringSubviewToFront(activityView)
        activityView.isHidden = false
        
        DispatchQueue.global(qos: .utility).async {
            
            let url = URL(string: self.pdfURLs[tab])!
            let document = PDFDocument(url: url)
            
            DispatchQueue.main.async {
                
                if let document = document {
                    self.activityView.isHidden = true
                    self.activityIndicator.isHidden = true
                    self.pdfView?.document = document
                    self.displayView.bringSubviewToFront(self.pdfView!)
                } else {
                    print("Instructions did not exist for part \(tab) of \(self.setNameLabel.text ?? "")")
                    self.activityIndicator.isHidden = true
                    self.activityLabel.text = "There was an error loading this document"
                }
            }
        }
        
    }
    
    
    @objc func tabButtonTapped(_ sender: UIButton) {
        if sender.tag != currentTab {
            switchToTab(sender.tag)
        }
    }
    
    
    
}
