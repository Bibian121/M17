//
//  ViewController.swift
//  M17_Concurrency
//
//  Created by Maxim NIkolaev on 08.12.2021.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private var arrayURLs = [
    "https://bipbap.ru/wp-content/uploads/2017/04/0_7c779_5df17311_orig.jpg",
    "https://st.depositphotos.com/2547675/3009/i/450/depositphotos_30094505-stock-photo-time-clock.jpg",
    "https://s1.1zoom.ru/big0/52/Love_Sunrises_and_sunsets_Fingers_Hands_Heart_Sun_532758_1280x897.jpg",
    "https://oboi-telefon.ru/wallpapers/10232/39615.jpg",
    "https://images.wallpaperscraft.ru/image/single/kanada_britanskaya_kolumbiya_gory_ozero_100429_225x300.jpg"
    ]
    
    private var images = [Data]()
    
    let service = Service()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 220, y: 220, width: 140, height: 140))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        stackView.addSubview(imageView)
        stackView.addArrangedSubview(activityIndicator)
        activityIndicator.startAnimating()
        setupViews()
        onLoad()
    }
    
    private func setupViews() {
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.left.right.equalToSuperview()
        }
    }

    private func onLoad() {
        let group = DispatchGroup()
        for i in 0...4 {
            group.enter()
            asyncLoad(imageURL: URL(string: arrayURLs[i])!,
                      runQueue: DispatchQueue.global(),
                      completionQueue: DispatchQueue.main)
            { result, error in
                guard let image1 = result else {return}
                print("---finished \(i) prioritet = \(qos_class_self().rawValue)")
                self.images.append(image1)
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.stackView.removeArrangedSubview(self.activityIndicator)
            for i in 0...4 {
                self.addImage(data: self.images[i])
            }
        }
    }
}

private extension ViewController {
    func asyncLoad(
        imageURL: URL,
        runQueue: DispatchQueue,
        completionQueue: DispatchQueue,
        completion: @escaping (Data?, Error?) -> ()
    ) {
        runQueue.async {
            do {
                let data = try Data(contentsOf: imageURL)
                completionQueue.async { completion(data, nil)}
            } catch let error {
                completionQueue.async { completion(nil, error)}
            }
        }
    }
    
    func addImage(data: Data) {
        let view = UIImageView(image: UIImage(data: data))
        view.contentMode = .scaleAspectFit
        self.stackView.addArrangedSubview(view)
    }
    
    
}

