//
//  Database.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import Foundation

protocol DatabaseProtocol: class
{
    //User
    func setToken(token: String?)
    func getToken() -> String?
}