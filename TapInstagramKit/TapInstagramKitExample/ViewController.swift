//
//  ViewController.swift
//  TapInstagramKitExample
//
//  Created by Osama Rabie on 10/21/20.
//

import UIKit
import TapInstagramKit
import Kingfisher

class ViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var instagrabWebController: TapWebInstagramWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userTextField.delegate = self
        loading.isHidden = true
    }
    
    func fetchTheData(from:String?) {
        guard let from = from else {
            return
        }
        loading.isHidden = false
        instagrabWebController.delegate = self
        instagrabWebController.fetchData(for: from)
    }
}


extension ViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fetchTheData(from: textField.text)
        textField.resignFirstResponder()
        return true
    }
}


extension ViewController:TapWebInstagramWebViewDelegate {
    func loadingFailed(with error: String) {
        loading.isHidden = true
        print(error)
    }
    
    func loadingFinished(with imageURL: URL?, parsedHTML: String) {
        loading.isHidden = true
        guard let url = imageURL else { return }
        self.imageView.kf.setImage(with: url)
    }
}




