//
//  secondHandViewController.swift
//  Conventions
//
//  Created by David Bahat on 30/09/2017.
//  Copyright © 2017 Amai. All rights reserved.
//

import Foundation

class SecondHandViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, SecondHandFormProtocol, UIScrollViewDelegate {
    
    @IBOutlet private weak var refreshIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var noItemsFoundLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    // Keeping the tableController as a child so we'll be able to add other subviews to the current
    // screen's view controller (e.g. snackbarView)
    private let tableViewController = UITableViewController()
    
    var forms: Array<SecondHand.Form> {
        get {
            return Convention.instance.secondHand.forms
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: SecondHandFormHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: SecondHandFormHeaderView.self))
        tableView.register(UINib(nibName: String(describing: SecondHandItemViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SecondHandItemViewCell.self))
        
        addRefreshController()
        
        noItemsFoundLabel.isHidden = forms.count > 0
        tableView.isHidden = forms.count == 0
        
        tableView.estimatedSectionHeaderHeight = 70
        tableView.estimatedRowHeight = 70
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return forms.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms[section].items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: SecondHandFormHeaderView.self)) as! SecondHandFormHeaderView
        headerView.form = forms[section]
        headerView.delegate = self
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SecondHandItemViewCell.self)) as! SecondHandItemViewCell
        let form = forms[indexPath.section]
        let item = form.items[indexPath.row]
        cell.bind(item: item, isFormClosed: form.closed)
        
        return cell
    }
    
    func removeWasClicked(formId: Int) {
        if let formIndex = forms.index(where: {$0.id == formId}) {
            Convention.instance.secondHand.forms.remove(at: formIndex)
            tableView.reloadData()
            noItemsFoundLabel.isHidden = forms.count > 0
            tableView.isHidden = forms.count == 0
        }
    }
    
    func refresh() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Convention.instance.secondHand.refresh({success in
            self.tableViewController.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if (!success) {
                TTGSnackbar(message: "לא ניתן לעדכן. בדוק חיבור לאינטרנט", duration: TTGSnackbarDuration.middle, superView: self.view).show()
                return
            }
            
            self.tableView.reloadData()
            self.noItemsFoundLabel.isHidden = self.forms.count > 0
            self.tableView.isHidden = self.forms.count == 0
        })
    }
    
    @IBAction func addFormWasClicked(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "הוספת טופס", message: "הכנס את מספר הטופס", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "בטל", style: .cancel) { (result : UIAlertAction) -> Void in }
        let okAction = UIAlertAction(title: "הוסף", style: .default) { (result : UIAlertAction) -> Void in
            
            guard let formId = Int(alertController.textFields![0].text!) else {
                TTGSnackbar(message: "מספר טופס לא תקין", duration: TTGSnackbarDuration.middle, superView: self.view).show()
                return
            }
            
            if formId < 0 || formId > 999 {
                TTGSnackbar(message: "מספר טופס לא תקין", duration: TTGSnackbarDuration.middle, superView: self.view).show()
                return
            }
            
            let newForm = SecondHand.Form(id: formId)
            self.refreshIndicatorView.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            newForm.refresh({success in
                self.refreshIndicatorView.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if !success {
                    TTGSnackbar(message: "לא ניתן להוסיף את הטופס", duration: TTGSnackbarDuration.middle, superView: self.view).show()
                    return
                }
                
                Convention.instance.secondHand.forms.append(newForm)
                self.tableView.reloadData()
                
                self.noItemsFoundLabel.isHidden = self.forms.count > 0
                self.tableView.isHidden = self.forms.count == 0
            })
        }
        
        alertController.addTextField(configurationHandler: {textField in })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Needed so the events can be invisible when scrolled behind the sticky header.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            guard let navController = navigationController else {
                continue
            }
            
            let hiddenFrameHeight = scrollView.contentOffset.y + navController.navigationBar.frame.size.height - cell.frame.origin.y
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                if let customCell = cell as? SecondHandItemViewCell {
                    customCell.maskCell(fromTop: hiddenFrameHeight)
                }
            }
        }
    }
    
    // TODO - Remove duplication with EventsViewController
    private func addRefreshController() {
        // Adding a tableViewController for hosting a UIRefreshControl.
        // Without a table controller the refresh control causes weird UI issues (e.g. wrong handling of
        // sticky section headers).
        tableViewController.tableView = tableView;
        tableViewController.refreshControl = UIRefreshControl()
        tableViewController.refreshControl?.tintColor = Colors.colorAccent
        tableViewController.refreshControl?.addTarget(self, action: #selector(SecondHandViewController.refresh), for: UIControlEvents.valueChanged)
        tableViewController.refreshControl?.backgroundColor = UIColor(hexString: "#A6B6B3")
        addChildViewController(tableViewController)
        tableViewController.didMove(toParentViewController: self)
    }
}
