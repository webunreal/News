//
//  HomeViewController.swift
//  News
//
//  Created by Nikolai Ivanov on 09.02.2021.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var menuViewTrailing: NSLayoutConstraint!
    @IBOutlet private weak var pickerViewTop: NSLayoutConstraint!
    @IBOutlet private weak var newsCategory: UILabel!
    @IBOutlet private weak var newsCountry: UILabel!
    @IBOutlet private weak var pickerView: UIPickerView!
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    private var whichPickerIsShown: Picker = .category
    private let network = Network()
    private var news: [News] = []
    private var showingMenu = false
    
    private var searchingText: String?
    private var selectedCategory = UserDefaults.standard.string(forKey: "selectedCategory") {
        didSet {
            updateUserDefaults()
            updateLabels()
        }
    }
    private var selectedCountry = UserDefaults.standard.string(forKey: "selectedCountry") {
        didSet {
            updateUserDefaults()
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
        
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
                            style: .plain,
                            target: target(forAction: #selector(changeSideMenuShowing), withSender: nil),
                            action: #selector(changeSideMenuShowing))
        
        let newsCategoryTap = UITapGestureRecognizer(target: self, action: #selector(showNewsCategoryPicker))
        let newsCountryTap = UITapGestureRecognizer(target: self, action: #selector(showNewsCountryPicker))
        newsCategory.isUserInteractionEnabled = true
        newsCategory.addGestureRecognizer(newsCategoryTap)
        newsCountry.isUserInteractionEnabled = true
        newsCountry.addGestureRecognizer(newsCountryTap)
        
        menuViewTrailing.constant = screenWidth
        pickerViewTop.constant = screenHeight
        
        updateLabels()
        loadNews()
    }
    
    @objc private func showNewsCategoryPicker() {
        whichPickerIsShown = .category
        showPicker()
    }
    
    @objc private func showNewsCountryPicker() {
        whichPickerIsShown = .country
        showPicker()
    }
    
    private func updateLabels() {
        self.newsCategory.text = selectedCategory
        self.newsCountry.text = selectedCountry
    }
    
    private func loadNews() {
        activityIndicator.startAnimating()
        network.loadNewsData(searchingText: searchingText, country: selectedCountry ?? "us", category: selectedCategory ?? "general") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let news):
                    self.news = news
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                case .failure:
                    let alert = UIAlertController(title: "Loading Error", message: "Couldn't load News", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Try again", style: UIAlertAction.Style.default) { _ in
                        self.loadNews()
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
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
        UIView.animate(withDuration: 0.2) {
            self.pickerViewTop.constant = self.screenHeight / 2
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func hidePicker(_ sender: UIButton) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.pickerViewTop.constant = self.screenHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func downloadNewsWithNewOptions(_ sender: UIButton) {
        loadNews()
        self.pickerViewTop.constant = self.screenHeight
        changeSideMenuShowing()
    }
    
    @objc private func changeSideMenuShowing() {
        showingMenu.toggle()
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.menuViewTrailing.constant = self.showingMenu ? self.screenWidth / 4 : self.screenWidth
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateUserDefaults() {
        UserDefaults.standard.set(selectedCategory, forKey: "selectedCategory")
        UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
    }
    
    //MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchingText = searchText
        loadNews()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchingText = nil
        view.endEditing(true)
        searchBar.showsCancelButton = false
        loadNews()
    }
    
    //MARK: - PickerView
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
    
    //MARK: - Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetailedViewController",
              let cell = sender as? HomeTableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let detailedViewController = segue.destination as? DetailedViewController
              else { return }
        
        detailedViewController.urlToSource = news[indexPath.row].urlToSource
        detailedViewController.urlToImageFromSegue = news[indexPath.row].urlToImage
        detailedViewController.titleFromSegue = news[indexPath.row].title
        detailedViewController.contentFromSegue = news[indexPath.row].content
    }
    
    //MARK: - Table View
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell
        else { return UITableViewCell(style: .default, reuseIdentifier: "") }
        
        var title = news[indexPath.row].title
        if let afterDash = title.range(of: " - ") {
            title.removeSubrange(afterDash.lowerBound..<title.endIndex)
        }
        
        cell.title.text = title
        cell.newsDescription.text = news[indexPath.row].description ?? ""
        
        if let imageURL = news[indexPath.row].urlToImage {
            network.loadImage(imageUrl: imageURL) { image in
                cell.newsImage.image = image
            }
        } else {
            cell.newsImage.image = UIImage(named: "noImage")
        }
        return cell
    }
}
