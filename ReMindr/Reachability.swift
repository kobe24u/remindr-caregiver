//
//  File.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 27/03/2017.
//  Copyright © 2016 Priyanka Gopakumar. All rights reserved.
//

/*
 
 Open Source code retrieved from http://stackoverflow.com/questions/30743408/check-for-internet-connection-in-swift-2-ios-9
 Author: Alvin George
 Retrieved on 10/09/2016
 Checks the device for internet connection.
 */

import Foundation
import SystemConfiguration

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)}
            //SCNetworkReachabilityCreateWithAddress(nil, zeroAddress)
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
    }
}
