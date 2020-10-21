//
//  TapWebInstagramWebView.swift
//  TapInstagramKit
//
//  Created by Osama Rabie on 10/21/20.
//

import UIKit
import WebKit

/// The delegate to communicate the result back from the TapInstagramWebView
@objc public protocol TapWebInstagramWebViewDelegate {
    /**
     Will be called when facing any error loading the data for the given instagram handler
     - parameter error: A string representation of the error occured
     */
    @objc func loadingFailed(with error:String)
    /**
     Will be called when the data is fetched from Instagram
     - parameter imageURL: A url for the profile picture
     - parameter parsedHTML : The whole HTML fetched from Instagram url, for further processing if needed
     */
    @objc func loadingFinished(with imageURL:URL?,parsedHTML:String)
}

/// The view that will be used to render the data from Instagram and pass back the result + the loaded HTML for further processing on demand
@objc public class TapWebInstagramWebView: UIView {

    // MARK:- Outlets
    /// Represents the content view that holds all the subviews
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var webView: WKWebView!
    
    /// The delegate to communicate the result back from the TapInstagramWebView
    @objc public var delegate:TapWebInstagramWebViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        self.contentView.backgroundColor = .clear
    }
    
    
    
    // MARK:- Public methods
    /**
     Starts the process for fetching the data from Instagram web for the given username
     - parameter instagramUserName: A string representation of the instagram user name required
     */
    @objc public func fetchData(for instagramUserName:String) {
        webView.navigationDelegate = self
        let stringURL = "https://instagram.com/\(instagramUserName)"
        guard let url:URL = URL(string: stringURL) else {
            delegate?.loadingFailed(with: "Cannot create a url from : \(stringURL)")
            return
        }
        
        webView.load(.init(url: url))
    }
}



extension TapWebInstagramWebView:WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("FINISHED : \(webView.url?.absoluteString ?? "")")
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    guard let html:String = html as? String else {
                                        self.delegate?.loadingFailed(with: "Cannot load HTML from : \(webView.url?.absoluteString ?? "")")
                                        return
                                    }
                                    let links:[String] = html.components(separatedBy: "/s150x150/")
                                    guard links.count > 1, let firstPart:String = links[0].components(separatedBy: "https:").last else {
                                        self.delegate?.loadingFinished(with: nil, parsedHTML: html)
                                        return
                                    }
                                    let lastPart:String = links[1].components(separatedBy: "\"")[0]
                                    
                                    var imageLink:String = "https:\(firstPart)/s150x150/\(lastPart)"
                                    
                                    imageLink = imageLink.replacingOccurrences(of: "&amp;", with: "&")
                                    guard let url:URL = URL(string: imageLink) else {
                                        self.delegate?.loadingFinished(with: nil, parsedHTML: html)
                                        return
                                    }
                                    self.delegate?.loadingFinished(with: url, parsedHTML: html)
                                    print("Link : \(imageLink)")
                                   })
    }
}

fileprivate extension UIView {
    // MARK:- Loading a nib dynamically
    /**
     Load a XIB file into a UIView
     - Parameter bundle: The bundle to load the XIB from, default is the XIB containing the UIView
     - Parameter identefier: The name of the XIB, default is the name of the UIView
     - Parameter addAsSubView: Indicates whether the method should add the loaded XIB into the UIView, default is true
     */
    func setupXIB(from bundle:Bundle? = nil, with identefier: String? = nil, then addAsSubView:Bool = true) -> UIView {
        
        // Whether we use the passed bundle if any, or by default we use the bundle that contains the caller UIView
        let bundle = bundle ?? Bundle(for: Self.self)
        // Whether we use the passed identefier if any, or by default we use the default identefier for self
        let identefier = identefier ??  String(describing: type(of: self))
        
        // Load the XIB file
        guard let nibs = bundle.loadNibNamed(identefier, owner: self, options: nil),
              nibs.count > 0, let loadedView:UIView = nibs[0] as? UIView else { fatalError("Couldn't load Xib \(identefier)") }
        
        let newContainerView = loadedView
        
        //Set the bounds for the container view
        newContainerView.frame = bounds
        newContainerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        // Check if needed to add it as subview
        if addAsSubView {
            addSubview(newContainerView)
        }
        return newContainerView
    }
}
