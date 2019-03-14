//
//  InstructionsViewController.swift
//  Lego Instructions
//
//  Created by Gabriel Blaine Palmer on 2/4/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import PDFKit

class InstructionsViewController: UIViewController, PDFViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    @IBOutlet weak var tabsStackViewTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var tabsStackViewLeadingSpace: NSLayoutConstraint!
    
    @IBOutlet weak var partsTableView: UITableView!
    
    var parts: [LegoPart]?
    var pdfURLs: [String] = []
    var currentTab: Int = 0
    
    //used for state restoration
    fileprivate var savedPageIndex: Int?
    fileprivate var savedTabIndex: Int?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partsTableView.dataSource = self
        partsTableView.delegate = self
        
        print("InstructionsViewController did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if legoSet == nil {
            activityIndicator.isHidden = true
            setNameLabel.text = "No Build Selected"
            infoButton.isHidden = true
            displayView.bringSubviewToFront(activityView)
            activityView.isHidden = false
            
        } else {
            infoButton.isHidden = false
            activityView.isHidden = true
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let pdfView = pdfView {
            let widthScale = size.width / view.bounds.width
            let newScale = pdfView.scaleFactor * widthScale
            pdfView.scaleFactor = newScale
        }
    }
    
    func pdfFitPage() {
        guard let pdf = self.pdfView, let doc = pdf.document, doc.pageCount > 0 else { return }
        pdf.autoScales = true
        pdf.scaleFactor = pdf.scaleFactorForSizeToFit
        pdf.minScaleFactor = pdf.scaleFactor - (pdf.scaleFactor / 4.0)
        pdf.maxScaleFactor = 3
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
            activityLabel.text = "Could not find any of the instructions listed.\nThis was probably caused by inaccurate info on brickset.com"
            activityIndicator.isHidden = true
            displayView.bringSubviewToFront(activityView)
            activityView.isHidden = false
            return
        }
        
        
        switch pdfURLs.count {
        case 2:
            tabsStackView.spacing = 28
            tabsStackViewLeadingSpace.constant = 28
            tabsStackViewTrailingSpace.constant = 28
        case 3:
            tabsStackView.spacing = 21
            tabsStackViewLeadingSpace.constant = 21
            tabsStackViewTrailingSpace.constant = 21
        case 4:
            tabsStackView.spacing = 14
            tabsStackViewLeadingSpace.constant = 14
            tabsStackViewTrailingSpace.constant = 14
        default:
            tabsStackView.spacing = 7
            tabsStackViewLeadingSpace.constant = 7
            tabsStackViewTrailingSpace.constant = 7
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
        
        //restores
        if let savedTabIndex = savedTabIndex {
            switchToTab(savedTabIndex)
            self.savedTabIndex = nil
        } else {
            switchToTab(0)
        }
        
    }
    
    func switchToTab(_ tab: Int) {
        currentTab = tab
        
        for button in tabsStackView.arrangedSubviews {
            if currentTab != button.tag {
                button.backgroundColor = #colorLiteral(red: 0.7672145258, green: 0.7784764083, blue: 0.8122620558, alpha: 1)
            } else {
                button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
        }
        
        //creates the PDFView the first time it's needed
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
            
            let url = URL(string: self.pdfURLs[self.currentTab])!
            let document = PDFDocument(url: url)
            
            DispatchQueue.main.async {
                
                if let document = document {
                    self.activityView.isHidden = true
                    self.activityIndicator.isHidden = true
                    self.pdfView?.document = document
                    self.pdfFitPage()
                    
                    if let savedPageIndex = self.savedPageIndex, let page = document.page(at: savedPageIndex) {
                        self.pdfView?.go(to: page)
                        self.savedPageIndex = nil
                    }
                    
                    self.displayView.bringSubviewToFront(self.pdfDisplayView)
                } else {
                    print("Instructions did not exist for part \(self.currentTab) of \(self.setNameLabel.text ?? "")")
                    self.activityIndicator.isHidden = true
                    self.activityLabel.text = "There was an error loading this document"
                }
            }
        }
        
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
        
        if let legoSet = legoSet {
            LegoPartsController.shared.fetchParts(bricksetLegoSet: legoSet) { (parts) in
                if let parts = parts {
                    print(parts)
                } else {
                    print("no parts found")
                }
                
            }
        }
        
    }
    
    //===========================================
    // MARK: - State Preservation
    //===========================================
    
    //state preservation functions are run after the view loads
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        guard let pdfView = pdfView, let document = pdfView.document, let page = pdfView.currentPage else { return }
        let pageIndex = document.index(for: page)
        coder.encode(pageIndex, forKey: "pageIndex")
        coder.encode(currentTab, forKey: "tabIndex")
        coder.encode(legoSet, forKey: "legoSet")
    }

    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        if let set = coder.decodeObject(forKey: "legoSet") as? LegoSet {
            legoSet = set
            savedPageIndex = coder.decodeInteger(forKey: "pageIndex")
            savedTabIndex = coder.decodeInteger(forKey: "tabIndex")
        }
    }
    
    //===========================================
    // MARK: - Parts Table View Delegate
    //===========================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}

