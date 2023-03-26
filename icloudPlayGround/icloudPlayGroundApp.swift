//
//  icloudPlayGroundApp.swift
//  icloudPlayGround
//
//  Created by Lenard Howell on 3/26/23.
//

import SwiftUI
import CloudKit

@main
struct icloudPlayGroundApp: App {
    
    // public Container
    let container = CKContainer(identifier: "iCloud.com.len.howell.icloudPlayGround")
    var body: some Scene {
        WindowGroup {
            ContentView(vm: ItemListViewModel(container:container))
        }
    }
}
