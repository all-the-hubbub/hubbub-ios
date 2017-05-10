//
//  Config.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/8/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Foundation

struct Config {
    // Always the real id so the upgrade dialog can properly open the App Store
    static let AppStoreID = "id1234046078"
    
    static let FirebasePlistName = env(
        dev: "GoogleService-Info-Dev",
        prod: "GoogleService-Info"
    )
    
    static let StaticHost = env(
        dev: "hubbub-staging.firebaseapp.com",
        prod: "hubbub-159904.firebaseapp.com"
    )
    
    static let FunctionsHost = env(
        dev: "us-central1-hubbub-staging.cloudfunctions.net",
        prod: "us-central1-hubbub-159904.cloudfunctions.net"
    )
    
    static let GitHubOAuthClientID = env(
        dev: "8047073cafed8937f908",
        prod: "077cb2f4568e245a97eb"
    )
    
    static let GitHubOAuthClientSecret = env(
        dev: "e7bcb695368e2ed41c2c0a5bdc0b64e8487c0840",
        prod: "aa4b736a317532b47202cb7c9820bba587e64a70"
    )
}

func env<T>(dev development: T, prod production:T) -> T {
    var v: T!
    
    #if ENV_DEV
        v = development
    #else
        v = production
    #endif
    
    return v
}
