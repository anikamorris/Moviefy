//
//  LoginViewController.swift
//  Moviefy
//
//  Created by Anika Morris on 7/12/20.
//  Copyright © 2020 Adriana González Martínez. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices

class LoginViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        APIClient.shared.createRequestToken { (result) in
            switch result{
            case let .success(token):
            DispatchQueue.main.async {
                print(token.request_token)
                self.authorizeRequestToken(from: self, requestToken: token.request_token)
            }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizeRequestToken(from viewController: UIViewController, requestToken: String) {
        // Use the URL and callback scheme specified by the authorization provider.
        guard let authURL = URL(string: "https://www.themoviedb.org/authenticate/\(requestToken)?redirect_to=moviefy://auth") else { return }
            let scheme = "auth"
            // Initialize the session using the class from AuthenticationServices
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme)
            { callbackURL, error in
              // Handle the callback.
              guard error == nil, let callbackURL = callbackURL else { return }

              // The callback URL format depends on the provider.
              let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
              print(queryItems!)
              guard let requestToken = queryItems?.first(where: { $0.name == "request_token" })?.value else { return }
              let approved = (queryItems?.first(where: { $0.name == "approved" })?.value == "true")

              print("Request token \(requestToken) \(approved ? "was" : "was NOT") approved")

              self.startSession(requestToken: requestToken) { success in
                print("Session started")
              }
            }
            session.presentationContextProvider = self
            session.start()
    }
    
    func startSession(requestToken: String, completion: @escaping (Bool) -> Void) {
        APIClient.shared.createSession(requestToken: requestToken) { (result) in
            switch result {
            case let .success(session):
               DispatchQueue.main.async {
                 print(session.session_id)
               }
            case let .failure(error):
                  print(error)
            }
        }
    }
}
