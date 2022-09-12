//
//  SceneDelegate.swift
//  Virtual_Tourist
//
//  Created by Joel Gans on 8/28/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: "Virtual_Tourist")
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        dataController.load()
        let navigationView = self.window?.rootViewController as! UINavigationController
        let mainView = navigationView.topViewController as! MapViewController
        mainView.dataController = self.dataController
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        saveViewContext()
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

