//
//  AppDelegate.swift
//  SwiftDemo
//
//  Created by qiang xu on 2021/2/4.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // 测试Wrapper
        let wrapper = WrapperDemo()
        wrapper.run()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

