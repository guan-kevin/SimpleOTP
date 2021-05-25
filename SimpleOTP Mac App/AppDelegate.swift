//
//  AppDelegate.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/24/21.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var eventMonitor: EventMonitor?
    var model: MainViewModel?

    var lastDate: Int?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()

        self.model = MainViewModel()

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView.environmentObject(self.model!))
        self.popover = popover

        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))

        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "ellipsis.rectangle", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 20, weight: .medium))
            button.action = #selector(self.togglePopover(_:))
        }

        self.eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.eventMonitor?.stop()
            // stop timer
            self?.model?.stopTimer()
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.makeKey()
                self.eventMonitor?.start()
                self.model?.startTimer()

                if self.lastDate != nil {
                    if Int(Date().timeIntervalSince1970) - self.lastDate! >= 5 {
                        self.model?.list()
                    }
                }
                
                self.lastDate = Int(Date().timeIntervalSince1970)
            }
        }
    }
}
