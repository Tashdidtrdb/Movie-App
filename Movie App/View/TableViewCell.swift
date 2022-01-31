//
//  TableViewCell.swift
//  Movie App
//
//  Created by BS198 on 28/1/22.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicationView: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTrailingConstraint: NSLayoutConstraint!
    
    var movieServer = MovieServer()
    var movies: [Movie] = []
    
    var genreId: Int?
    var currentPage: Int?
    var pagesRemaining = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(CollectionViewCell.nib(), forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
    }
    
    func configure(with genre: Genre, page: Int, previousMovies: [Movie], offset: CGPoint) {
        genreId = genre.id; movies = previousMovies; currentPage = page
        genreLabel.text = genre.name.uppercased()
        collectionView.contentOffset = offset
        collectionView.reloadData()
        
        if movies.isEmpty {
            guard let genreId = genreId, let currentPage = currentPage else { return }
            fetchMovies(genreId: genreId, page: currentPage)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movies = []
    }
    
    func fetchMovies(genreId: Int, page: Int, resetCollectionViewOffset: Bool = false) {
        activityIndicationView.startAnimating()
        showPreviousButton(false)
        showNextButton(false)
        
        movieServer.fetchMovies(genreId: genreId, page: page) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let movieResponse):
                self.movies.append(contentsOf: movieResponse.results)
                self.currentPage = movieResponse.page
                if movieResponse.page == movieResponse.total_pages {
                    self.pagesRemaining = false
                }
                DispatchQueue.main.async {
                    self.activityIndicationView.stopAnimating()
                    self.collectionView.reloadData()
                    if resetCollectionViewOffset {
                        self.collectionView.setContentOffset(.zero, animated: true)
                        if movieResponse.page != 1 {
                            self.showPreviousButton(true)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - ScrollView delegate

extension TableViewCell: ScrollViewDelegate {
    static let identifier = "TableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

// MARK: - Previous and Next button actions

extension TableViewCell {
    func showPreviousButton(_ visibility: Bool) {
        previousButton.isHidden = !visibility
        collectionViewLeadingConstraint.constant = visibility ? 25 : 10
    }
    
    func showNextButton(_ visibility: Bool) {
        nextButton.isHidden = !visibility
        collectionViewTrailingConstraint.constant = visibility ? 25 : 10
    }
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        guard let genreId = genreId, let currentPage = currentPage else { return }
        fetchMovies(genreId: genreId, page: currentPage - 1, resetCollectionViewOffset: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        guard let genreId = genreId, let currentPage = currentPage else { return }
        fetchMovies(genreId: genreId, page: currentPage + 1, resetCollectionViewOffset: true)
    }
}

// MARK: - CollectionView delegate and datasource

extension TableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        showPreviousButton(currentPage! > 1 && collectionView.contentOffset.x <= .zero ? true : false)
//        showNextButton(pagesRemaining && collectionView.contentOffset.x + collectionView.frame.size.width >= collectionView.contentSize.width ? true : false)
//    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
}

// MARK: - CollectionView Prefetching

extension TableViewCell: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last else { return }
        if lastIndexPath.row >= movies.count - 5 {
            guard let genreId = genreId, let currentPage = currentPage else { return }
            fetchMovies(genreId: genreId, page: currentPage + 1)
        }
    }
}
