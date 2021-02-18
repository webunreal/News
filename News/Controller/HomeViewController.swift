//
//  HomeViewController.swift
//  News
//
//  Created by Nikolai Ivanov on 09.02.2021.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var menuViewTrailing: NSLayoutConstraint!
    @IBOutlet weak private var pickerViewTop: NSLayoutConstraint!
    @IBOutlet weak private var newsCategory: UILabel!
    @IBOutlet weak private var newsCountry: UILabel!
    @IBOutlet weak private var pickerView: UIPickerView!
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    private var whichPickerIsShown: Picker = .category
    private let network = Network()
    private var news: [News] = []
    private var showingMenu = false
   
    private var selectedCategory = "General" {
        didSet {
            updateLabels()
        }
    }

    private var selectedCountry = "us" {
        didSet {
            updateLabels()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style:.plain, target: target(forAction: #selector(changeSideMenuShowing), withSender: nil), action: #selector(changeSideMenuShowing))
        
        menuViewTrailing.constant = screenWidth
        pickerViewTop.constant = screenHeight
        
        loadNews(searchingText: nil)
        updateLabels()
    }
    
    private func loadNews(searchingText: String?) {
        activityIndicator.startAnimating()
        network.loadData(searchingText: searchingText, country: selectedCountry, category: selectedCategory.lowercased(), completion: { result in
            switch result {
            case .success(let news):
                self.news = news
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            case .failure(let error):
                print("Fetch failed: \(error.localizedDescription)")
            }
        })
    }
    
    private func updateLabels() {
        self.newsCategory.text = selectedCategory
        self.newsCountry.text = selectedCountry
    }
    
    @IBAction private func showCategoryPicker(_ sender: UIButton) {
        whichPickerIsShown = .category
        showPicker()
    }
    
    @IBAction func showCountryPicker(_ sender: UIButton) {
        whichPickerIsShown = .country
        showPicker()
    }
    
    private func showPicker() {
        self.pickerViewTop.constant = UIScreen.main.bounds.height
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.pickerViewTop.constant = self.screenHeight / 2
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction private func hidePicker(_ sender: UIButton) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.pickerViewTop.constant = self.screenHeight
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction private func downloadNewsWithNewOptions(_ sender: UIButton) {
        loadNews(searchingText: nil)
        self.pickerViewTop.constant = self.screenHeight
        changeSideMenuShowing()
    }
    
    @objc private func changeSideMenuShowing() {
        showingMenu.toggle()
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.menuViewTrailing.constant = self.showingMenu ? self.screenWidth / 4 : self.screenWidth
            self.view.layoutIfNeeded()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadNews(searchingText: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        view.endEditing(true)
        searchBar.showsCancelButton = false
        loadNews(searchingText: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch whichPickerIsShown {
        case .category:
            return NewsParameters.categories.count
        case .country:
            return NewsParameters.countries.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch whichPickerIsShown {
        case .category:
            return NewsParameters.categories[row]
        case .country:
            return NewsParameters.countries[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch whichPickerIsShown {
        case .category:
            selectedCategory = NewsParameters.categories[row]
        case .country:
            selectedCountry = NewsParameters.countries[row]
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailedViewController" {
            guard let detailedViewController = segue.destination as? DetailedViewController else { return }
            guard let indexPath = tableView.indexPath(for: (sender as? HomeTableViewCell)!) else { return }
            
            detailedViewController.urlToSource = news[indexPath.row].urlToSource
            detailedViewController.urlToImageFromSegue = news[indexPath.row].urlToImage
            detailedViewController.titleFromSegue = news[indexPath.row].title
            detailedViewController.contentFromSegue = news[indexPath.row].content
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        
        var title = news[indexPath.row].title
        if let afterDash = title.range(of: " - ") {
            title.removeSubrange(afterDash.lowerBound..<title.endIndex)
        }
        
        cell.title.text = title
        cell.newsDescription.text = news[indexPath.row].description ?? ""
        
        if let imageURL = news[indexPath.row].urlToImage {
            network.downloadImage(imageUrl: imageURL) { image in
                cell.newsImage.image = image
            }
        } else {
            cell.newsImage.image = UIImage(named: "noImage")
        }
        
        return cell
    }
    
    
}

