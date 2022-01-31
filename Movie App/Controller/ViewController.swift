//
//  ViewController.swift
//  Movie App
//
//  Created by BS198 on 28/1/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movieServer = MovieServer()
    var genres: [Genre] = []
    
    var cachedCollectionViewPosition = Dictionary<IndexPath, CGPoint>()
    var cachedCollectionViewPage = Dictionary<IndexPath, Int>()
    var cachedDataInCollectionView = Dictionary<IndexPath, [Movie]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.register(TableViewCell.nib(), forCellReuseIdentifier: TableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchGenres()
    }
    
    func fetchGenres() {
        movieServer.fetchGenres() { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let genreResponse):
                self.genres = genreResponse.genres
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - TableView delegate and datasource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return genres.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as! TableViewCell
        cell.configure(with: genres[indexPath.section], page: cachedCollectionViewPage[indexPath] ?? 1, previousMovies: cachedDataInCollectionView[indexPath] ?? [], offset: cachedCollectionViewPosition[indexPath] ?? .zero)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TableViewCell {
            cachedCollectionViewPosition[indexPath] = cell.collectionView.contentOffset
            cachedCollectionViewPage[indexPath] = cell.currentPage
            cachedDataInCollectionView[indexPath] = cell.movies
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(200)
    }

}
