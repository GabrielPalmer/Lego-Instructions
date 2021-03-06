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
    @IBOutlet weak var displayViewLeadingSpacing: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var partsButton: UIButton!
    @IBOutlet weak var tabsStackView: UIStackView!
    @IBOutlet weak var tabsStackViewLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var tabsStackViewTrailingSpace: NSLayoutConstraint!
    
    @IBOutlet weak var partsView: UIView!
    @IBOutlet weak var partLabel: UILabel!
    @IBOutlet weak var partsViewLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var partsViewWidth: NSLayoutConstraint!
    @IBOutlet weak var partsTableView: UITableView!
    
    var partsVisible: Bool = false
    var partsLoaded: Bool = false
    var parts: [LegoPart]?
    var selectedPartsCell: UITableViewCell?
    
    var pdfURLs: [String] = []
    var currentTab: Int = 0
    
    //used for state restoration
    fileprivate var savedPageIndex: Int?
    fileprivate var savedTabIndex: Int?
    
    var legoSet: LegoSet? {
        didSet {
            
            partsLoaded = false
            partsVisible = false
            partsViewWidth.constant = 0
            displayViewLeadingSpacing.constant = 0
            
            guard let legoSet = legoSet else { return }
            setNameLabel.text = legoSet.name
            partsButton.isHidden = false
            
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

        setNameLabel.adjustsFontSizeToFitWidth = true
        partsViewWidth.constant = 0
        partsTableView.dataSource = self
        partsTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if legoSet == nil {
            activityIndicator.isHidden = true
            setNameLabel.text = "No Build Selected"
            displayView.bringSubviewToFront(activityView)
            activityView.isHidden = false
            partsButton.isHidden = true
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
        self.view.layoutIfNeeded()
        guard let pdf = self.pdfView, let doc = pdf.document, doc.pageCount > 0 else { return }
        pdf.scaleFactor = pdf.scaleFactorForSizeToFit
        pdf.minScaleFactor = pdf.scaleFactor - (pdf.scaleFactor / 4.0)
        pdf.maxScaleFactor = 3
    }
    
    func setUpTabsStackView() {
        
        //delete previous tabs
        tabsStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        guard pdfURLs.count > 0 else {
            activityLabel.text = "Error finding the listed instructions.\nCheck internet connection or find this set on brickset.com"
            activityIndicator.isHidden = true
            headerHeight.constant = 76
            tabsStackView.isHidden = true
            displayView.bringSubviewToFront(activityView)
            activityView.isHidden = false
            return
        }
        
        //tabs stack view won't display if there is only one page
        if pdfURLs.count < 2 {
            tabsStackView.isHidden = true
            headerHeight.constant = 76
            switchToTab(0)
            return
        } else {
            headerHeight.constant = 136
            tabsStackView.isHidden = false
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
            tabsStackViewLeadingSpace.constant = 14
            tabsStackViewTrailingSpace.constant = 14
        }
        
        let screenWidth = view.bounds.width
        let estimatedButtonWidth = ((screenWidth - 14.0) / CGFloat(integerLiteral: pdfURLs.count)) - tabsStackView.spacing
        
        for tabIndex in 0...pdfURLs.count - 1 {
            let slantLength: CGFloat = 15.0
            let button = SlantButton(frame: CGRect(x: 0, y: 0, width: estimatedButtonWidth + (2.0 * slantLength), height: 60))

            button.slantLength = slantLength
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            button.tag = tabIndex
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 22.0)
            button.backgroundColor = #colorLiteral(red: 0.8176259082, green: 0.822451515, blue: 0.8597715736, alpha: 1)
            button.titleLabel?.textColor = UIColor.black
            
            button.setTitle("\(tabIndex + 1)", for: .normal)
            
            tabsStackView.addArrangedSubview(button)
        }

        //restores state
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
            newPDFView.autoScales = true
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

        let url = URL(string: pdfURLs[currentTab])!
        DispatchQueue.global(qos: .utility).async {
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
                    self.activityLabel.text = "This document could not be loaded"
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
    
    @IBAction func partsButtonTapped(_ sender: Any) {
        if let legoSet = legoSet {
            
            partsVisible = !partsVisible
            
            if !partsLoaded {
                self.partsLoaded = true
                parts?.removeAll()
                partLabel.text = "Loading Parts..."
                LegoPartsController.shared.fetchParts(bricksetLegoSet: legoSet) { (parts) in
                    DispatchQueue.main.async {
                        if let parts = parts {
                            self.parts = parts
                            self.partLabel.text = "\(parts.count) Total Parts"
                        } else {
                            self.partLabel.text = "Could not load parts for this set"
                        }
                        
                        self.partsTableView.reloadData()
                    }
                }
            }

//            UIView.animate(withDuration: 0.3) {
//                self.partsViewWidth.constant = self.partsVisible ? 150 : 0
//                self.view.layoutIfNeeded()
//                self.pdfFitPage()
//            }


            // what the janky animations make it be
            view.layoutIfNeeded()

            UIView.animate(withDuration: 0.3, animations: {
                if self.partsVisible {
                    let scaleFactor = (self.pdfDisplayView.frame.width - 150) / self.pdfDisplayView.frame.width
                    self.pdfView?.scaleFactor = scaleFactor
                    self.view.layoutIfNeeded()
                } else {
                    self.partsViewWidth.constant = 0
                    self.pdfFitPage()
                }
            }) {(_) in
                if self.partsVisible {
                    self.partsViewWidth.constant = 150
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    //===========================================
    // MARK: - State Preservation
    //===========================================
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        if tabBarController?.selectedIndex != 1 {
            coder.encode(nil, forKey: "pageIndex")
            coder.encode(nil, forKey: "tabIndex")
            coder.encode(nil, forKey: "legoSet")
        } else {
            guard let pdfView = pdfView, let document = pdfView.document, let page = pdfView.currentPage else { return }
            let pageIndex = document.index(for: page)
            coder.encode(pageIndex, forKey: "pageIndex")
            coder.encode(currentTab, forKey: "tabIndex")
            coder.encode(legoSet, forKey: "legoSet")
        }
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
    // MARK: - Parts Table View
    //===========================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "partCell", for: indexPath) as! PartTableViewCell
        let part = parts![indexPath.row]
        if part.quantity == 0 {
            cell.quantityLabel.text = "%"
        } else {
            cell.quantityLabel.text = "x\(part.quantity)"
        }

        //deletes the quantity label for some reason
        cell.partImageView.image = UIImage(named: "blankImage")

        cellImage(for: part) { (image) in
            DispatchQueue.main.async {
                cell.partImageView.image = image
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if let selectedPartsCell = selectedPartsCell {
            selectedPartsCell.layer.borderWidth = 0
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = #colorLiteral(red: 0.04540421814, green: 0.6656955481, blue: 0.9993106723, alpha: 1)
            selectedPartsCell = cell
        }

        if let parts = parts {
            //updates the parts label
            //then recalculates the table views scroll position so the label doesn't move it
            let previousHeight = partLabel.frame.height
            let previousOffset = partsTableView.contentOffset.y
            partLabel.text = parts[indexPath.row].name
            view.layoutIfNeeded()
            let newHeight = partLabel.frame.height

            guard previousHeight != newHeight else { return }
            let difference = previousHeight - newHeight
            let newOffset = previousOffset - difference
            partsTableView.contentOffset.y = newOffset
        }
    }
    
    func cellImage(for item: LegoPart, completion: @escaping (UIImage?) -> Void) {
        
        if let url = URL(string: item.imageURL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(UIImage(named: "imageError"))
                }
                }.resume()
        } else {
            completion(UIImage(named: "imageError"))
        }
    }
    
}
