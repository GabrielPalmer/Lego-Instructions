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
    
    @IBOutlet weak var pdfDisplayView: UIView!
    var pdfView: PDFView?
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pdfFitPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if legoSet == nil {
            activityIndicator.isHidden = true
            setNameLabel.text = "No Set Selected"
            infoButton.isHidden = true
            displayView.bringSubviewToFront(activityView)
            activityView.isHidden = false
            
        } else {
            infoButton.isHidden = false
            activityView.isHidden = true
        }
        
    }
    
    func setUpTabsStackView() {
        
        //delete previous tabs if loading from search tab again
        tabsStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        //tab bar won't display if there is only one page
        if pdfURLs.count < 2 {
            tabsStackView.isHidden = true
            headerHeight.constant = 76
            switchToTab(0)
            return
        } else {
            headerHeight.constant = 136
            tabsStackView.isHidden = false
        }
        
        guard pdfURLs.count > 0 else {
            activityLabel.text = "Could not find the any of the instructions listed.\nThis was probably caused by inaccurate info on brickset.com"
            activityIndicator.isHidden = true
            displayView.bringSubviewToFront(activityView)
            activityView.isHidden = false
            return
        }
        
        let screenWidth = view.bounds.width
        let estimatedButtonWidth = ((screenWidth - 14.0) / CGFloat(integerLiteral: pdfURLs.count)) - tabsStackView.spacing
        
        for tabIndex in 0...pdfURLs.count - 1 {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: estimatedButtonWidth, height: 60))
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            
            button.tag = tabIndex
            button.titleLabel?.font = UIFont(name: "tabButton", size: 28.0)
            button.backgroundColor = #colorLiteral(red: 0.8176259082, green: 0.822451515, blue: 0.8597715736, alpha: 1)
            button.titleLabel?.textColor = UIColor.black
            
            button.setTitle("\(tabIndex + 1)", for: .normal)
            
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
            newPDFView.translatesAutoresizingMaskIntoConstraints = false
            pdfDisplayView.addSubview(newPDFView)
            
            let bottom = NSLayoutConstraint(item: newPDFView, attribute: .bottom, relatedBy: .equal, toItem: pdfDisplayView, attribute: .bottom, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint(item: newPDFView, attribute: .leading, relatedBy: .equal, toItem: pdfDisplayView, attribute: .leading, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: newPDFView, attribute: .top, relatedBy: .equal, toItem: pdfDisplayView, attribute: .top, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: newPDFView, attribute: .trailing, relatedBy: .equal, toItem: pdfDisplayView, attribute: .trailing, multiplier: 1, constant: 0)
            
            view.addConstraints([leading, trailing, top, bottom])
            
            pdfView = newPDFView
        }
        
        activityLabel.text = "Loading Instructions"
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
                    self.displayView.bringSubviewToFront(self.pdfDisplayView)
                } else {
                    print("Instructions did not exist for part \(tab) of \(self.setNameLabel.text ?? "")")
                    self.activityIndicator.isHidden = true
                    self.activityLabel.text = "There was an error loading the document"
                }
            }
        }
        
    }
    
    func pdfFitPage() {
        guard let pdf = self.pdfView, let doc = pdf.document, doc.pageCount > 0 else { return }
        pdf.scaleFactor = pdf.scaleFactorForSizeToFit
        pdf.minScaleFactor = pdf.scaleFactor
        pdf.maxScaleFactor = 3
        pdf.autoScales = true
        
    }
    
    //========================================
    // MARK: - Actions
    //========================================
    
    @objc func tabButtonTapped(_ sender: UIButton) {
        if sender.tag != currentTab {
            switchToTab(sender.tag)
        }
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        
        let setInfoView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 350))
        view.addSubview(setInfoView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: setInfoView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 350),
            NSLayoutConstraint(item: setInfoView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200),
            NSLayoutConstraint(item: setInfoView, attribute: .centerX, relatedBy: .equal, toItem: infoButton, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: setInfoView, attribute: .top, relatedBy: .equal, toItem: infoButton, attribute: .bottom, multiplier: 1, constant: 15)
            ])
        
        
//        let titleLabel = UILabel()
//        titleLabel.text = "Information About This LEGO Set"
//
//        let errorLabel1 = UILabel()
//        errorLabel1.numberOfLines = 0
//        errorLabel1.text = "Wrong Instructions?\n Make sure you selected the correct set.\nOtherwise this was probably caused by an inaccurate listing.\nUse the link to find the instructions online."
//
//        let button1 = UIButton()
//        button1.titleLabel?.text = "View on Brickset.com"
//
//        let errorLabel2 = UILabel()
//        errorLabel2.numberOfLines = 0
//        errorLabel2.text = "Missing Parts or Duplicates in Instructions?\nThe instruction parts are often unordered so try through looking again. Otherwise, when finding the listed parts of instruction for a set, this application automatically removes duplicates, but it isn't perfect and might have made a mistake. This happens expecially when working with older sets."
//
//        let button2 = UIButton()
//        button2.titleLabel?.text = "Show all instructions listed"
//
//        let stackView = UIStackView(arrangedSubviews: [titleLabel, errorLabel1, button1, errorLabel2, button2])
//        stackView.axis = .vertical
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        setInfoView.addSubview(stackView)
//
//        stackView.topAnchor.constraint(equalTo: setInfoView.topAnchor, constant: 6)
//        stackView.bottomAnchor.constraint(equalTo: setInfoView.bottomAnchor, constant: 6)
//        stackView.leadingAnchor.constraint(equalTo: setInfoView.leadingAnchor, constant: 6)
//        stackView.trailingAnchor.constraint(equalTo: setInfoView.trailingAnchor, constant: 6)
        
        
        
        
        
    }
    
    
}
