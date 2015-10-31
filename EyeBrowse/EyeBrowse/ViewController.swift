//
//  ViewController.swift
//  EyeBrowse
//
//  Created by 从今以后 on 15/10/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var searchBarBackgroundView: UIView!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var forwardButton: UIBarButtonItem!
    @IBOutlet private weak var stopReloadButton: UIBarButtonItem!

    private let webView = WKWebView()

    private lazy var context: UnsafeMutablePointer<Void> = {
        UnsafeMutablePointer<Void>(unsafeAddressOf(self))
    }()

    // MARK: - view 生命周期方法

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        configureSearchBar()
        adjustSearchBarWithScreenWidth(view.bounds.width)
    }

    // MARK: - KVO

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == self.context else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }

        switch keyPath! {
        case "estimatedProgress":

            let progress = Float(webView.estimatedProgress)
            // 加载中又重新加载,造成 estimatedProgress 从 0 开始,这时候不要使用动画.
            progressView.setProgress(progress, animated: progress > progressView.progress)

            print("progress: \(progress)")

        case "loading":
            let loading = webView.loading

            // 提示加载进度.
            progressView.hidden = !loading
            UIApplication.sharedApplication().networkActivityIndicatorVisible = loading
            if loading == false {
                // 加载完毕重置进度条.
                progressView.setProgress(0, animated: false)
            }

            // 切换停止/刷新按钮状态.
            stopReloadButton.image = loading ? UIImage(named: "icon_stop") : UIImage(named: "icon_refresh")

            print("loading: \(loading)")

        case "URL":
            searchBar.text = webView.URL?.absoluteString ?? searchBar.text // 如果有重定向这种情况 URL 会变化.
        case "canGoForward":
            forwardButton.enabled = webView.canGoForward
        case "canGoBack":
            backButton.enabled = webView.canGoBack
        default: break
        }
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        loadRequest()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        stopReloadButton.enabled = !searchText.isEmpty
    }
}

// MARK: - WKNavigationDelegate
extension ViewController: WKNavigationDelegate {

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
    }

    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        print("didCommitNavigation")
    }

    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        print("didFailProvisionalNavigation")
    }

    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print("didFailNavigation")
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("didFinishNavigation")
    }

    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }

    func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyForNavigationAction")
        decisionHandler(.Allow)
    }

    func webView(webView: WKWebView,
        decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse,
        decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        print("decidePolicyForNavigationResponse")
        decisionHandler(.Allow)
    }
}

// MARK: - Action
private extension ViewController {

    @IBAction func goBack(sender: UIBarButtonItem) {
        webView.goBack()
    }

    @IBAction func goForward(sender: UIBarButtonItem) {
        webView.goForward()
    }

    @IBAction func stopReload(sender: UIBarButtonItem) {
        if webView.loading {
            webView.stopLoading()
        } else {
            loadRequest()
        }
    }
}

// MARK: - 私有方法
private extension ViewController {

    func adjustSearchBarWithScreenWidth(width: CGFloat) {
        /*  titleView 会自动居中,只需调整宽度.两边各留 8 点间距.*/
        searchBarBackgroundView.bounds.size.width = width - 16
    }

    func configureSearchBar() {
        searchBar.returnKeyType = .Go // IB 里设置不管用啊...
        if let searchField = searchBar.valueForKey("_searchField") as? UITextField {
            searchField.clearButtonMode = .WhileEditing
        }
    }

    func setupWebView() {
        webView.navigationDelegate = self

        // 避免被底部工具栏遮挡
        webView.scrollView.contentInset.bottom = 44

        // 注册 KVO 监听.
        webView.addObserver(self, forKeyPath: "URL", options: NSKeyValueObservingOptions(), context: context)
        webView.addObserver(self, forKeyPath: "loading", options: NSKeyValueObservingOptions(), context: context)
        webView.addObserver(self, forKeyPath: "canGoBack", options: NSKeyValueObservingOptions(), context: context)
        webView.addObserver(self, forKeyPath: "canGoForward", options: NSKeyValueObservingOptions(), context: context)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions(), context: context)

        // 约束 webView 全屏显示.
        view.insertSubview(webView, belowSubview: progressView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        webView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        webView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        webView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
    }

    func loadRequest() {
        guard var searchText = searchBar.text else { return }
        if !searchText.hasPrefix("http://") {
            searchText = "http://" + searchText
        }
        webView.loadRequest(NSURLRequest(URL: NSURL(string: searchText)!))
    }
}
