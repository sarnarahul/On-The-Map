//
//  UdacityConstants.swift
//  On The Map-Udacity
//
//  Created by Rahul Sarna on 12/17/15.
//  Copyright © 2015 Rahul Sarna. All rights reserved.
//

//
//  TMDBConstants.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

// MARK: - TMDBClient (Constants)

extension UdacityAPIClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseApplicationID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        static let parseURLSecure : String = "https://api.parse.com/1/classes/"
        
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Session
        static let Session = "session"
        
        // MARK: Account
        static let Users = "users/"
        
        // MARK: Parse
        static let studentLocations = "StudentLocation"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let AccessToken = "access_token"
        static let Query = "query"
        static let Limit = "limit"
        static let Skip = "skip"
        static let order = "order"
        static let whereParam = "where"
        
        static let FacebookMobile = "facebook_mobile"
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        
        static let UniqueKey = "uniqueKey"
        static let ObjectId = "objectId"
        static let UpdatedAt = "updatedAt"
        
    }
    
}
