//
//  NavigationCoordinator.swift
//  SIPSDKExample
//
//  Created by 杨涛 on 2025/5/27.
//

import SIPFramework
import UIKit

class NavigationCoordinator {
    static let shared = NavigationCoordinator()

    func present(_ viewController: UIViewController, fullScreen: Bool = true, animated: Bool = true) {
        DispatchQueue.main.async {
            if fullScreen {
                viewController.modalPresentationStyle = .fullScreen
            }

            if let rootVC = Self.getRootViewController(),
               let topVC = Self.topViewController(from: rootVC)
            {
                topVC.present(viewController, animated: animated)
            }
        }
    }

    func push(_ viewController: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async {
            if let rootVC = Self.getRootViewController(),
               let nav = Self.topViewController(from: rootVC)?.navigationController
            {
                nav.pushViewController(viewController, animated: animated)
            }
        }
    }

    private static func getRootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }

    private static func topViewController(from vc: UIViewController?) -> UIViewController? {
        if let nav = vc as? UINavigationController {
            return topViewController(from: nav.visibleViewController)
        } else if let tab = vc as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        } else if let presented = vc?.presentedViewController {
            return topViewController(from: presented)
        } else {
            return vc
        }
    }
}
