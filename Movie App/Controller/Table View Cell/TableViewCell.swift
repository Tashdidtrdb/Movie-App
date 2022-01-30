//
//  TableViewCell.swift
//  Movie App
//
//  Created by BS198 on 28/1/22.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    static let identifier = "TableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewRightConstraint: NSLayoutConstraint!
    
    var networkManager = NetworkManager()
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
//        networkManager.delegate = self
    }
    
    func configure(with genre: Genre, page: Int, offset: CGPoint) {
        genreId = genre.id
        currentPage = page
        label.text = genre.name.uppercased()
        collectionView.contentOffset = offset
        
        fetchMovies(genreId: genreId!, page: currentPage!)
    }
    
    func fetchMovies(genreId: Int, page: Int, resetCollectionViewOffset: Bool = false) {
        spinner.startAnimating()
        showPreviousButton(false)
        showNextButton(false)
        
        networkManager.fetchMovies(genreId: genreId, page: page) { [weak self] response in
            switch response {
            case .success(let movieResponse):
                self?.movies = movieResponse.results
                self?.currentPage = movieResponse.page
                if movieResponse.page == movieResponse.total_pages {
                    self?.pagesRemaining = false
                }
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.collectionView.reloadData()
                    if resetCollectionViewOffset {
                        self?.collectionView.setContentOffset(.zero, animated: true)
                        if movieResponse.page != 1 {
                            self?.showPreviousButton(true)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Previous and Next button actions

extension TableViewCell {
    func showPreviousButton(_ visibility: Bool) {
        previousButton.isHidden = !visibility
        if visibility {
            collectionViewLeftConstraint.constant = 25
        } else {
            collectionViewLeftConstraint.constant = 10
        }
    }
    
    func showNextButton(_ visibility: Bool) {
        nextButton.isHidden = !visibility
        if visibility {
            collectionViewRightConstraint.constant = 25
        } else {
            collectionViewRightConstraint.constant = 10
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        fetchMovies(genreId: genreId!, page: currentPage! - 1, resetCollectionViewOffset: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        fetchMovies(genreId: genreId!, page: currentPage! + 1, resetCollectionViewOffset: true)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if currentPage! > 1 && collectionView.contentOffset.x <= .zero {
            showPreviousButton(true)
        } else {
            showPreviousButton(false)
        }

        if pagesRemaining && collectionView.contentOffset.x + collectionView.frame.size.width >= collectionView.contentSize.width {
            showNextButton(true)
        } else {
            showNextButton(false)
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
}

// MARK: - NetworkManager delegate

//extension TableViewCell: NetworkManagerDelegate {
//    func networkManger<T>(_ networkManager: NetworkManager, didFetchWithSuccess data: T) {
//        var movieResponse: MovieResponse = data as! MovieResponse
//        movies = movieResponse.results
//
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
//    }
//
//    func networkManager(_ networkManager: NetworkManager, didFailWithError error: Error) {
//        print(error)
//    }
//}
