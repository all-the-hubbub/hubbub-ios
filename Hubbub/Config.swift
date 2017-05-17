//
//  Config.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/8/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Foundation

struct Config {
    static let FirebasePlistName = env(
        dev: "GoogleService-Info",
        beta: "GoogleService-Info-Beta",
        prod: "GoogleService-Info-Prod"
    )
    
    static let AppStoreID = "id1234046078"
    
    //
    // MODIFY `dev` ENTRIES FOR SETTINGS BELOW THIS LINE
    //

    static let StaticHost = env(
        dev: "<PROJECT_ID>.firebaseapp.com",
        beta: "hubbub-staging.firebaseapp.com",
        prod: "hubbub-159904.firebaseapp.com"
    )

    static let FunctionsHost = env(
        dev: "us-central1-<PROJECT_ID>.cloudfunctions.net",
        beta: "us-central1-hubbub-staging.cloudfunctions.net",
        prod: "us-central1-hubbub-159904.cloudfunctions.net"
    )

    static let GitHubOAuthClientID = env(
        dev: "<GITHUB_OAUTH_CLIENT_ID>",
        beta: "8047073cafed8937f908",
        prod: "077cb2f4568e245a97eb"
    )
}

func env<T>(dev development: T, beta: T, prod production: T) -> T {
    var v: T!

    #if ENV_DEV
        v = development
    #elseif ENV_BETA
        v = beta
    #else
        v = production
    #endif

    return v
}
