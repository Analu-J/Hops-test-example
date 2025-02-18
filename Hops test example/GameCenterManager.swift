//
//  GameCenterManager.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/18/25.
//

import GameKit
import UIKit

class GameCenterManager: NSObject, GKGameCenterControllerDelegate {
    
    static let shared = GameCenterManager()
    
    // authenticates the local player. call this early (e.g., when your app launches or your main view appears).
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let vc = viewController {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(vc, animated: true)
                }
            } else if localPlayer.isAuthenticated {
                print("Player authenticated: \(localPlayer.displayName)")
            } else {
                if let error = error {
                    print("Game Center authentication failed: \(error.localizedDescription)")
                } else {
                    print("Game Center authentication failed for unknown reasons.")
                }
            }
        }
    }
    
    // submits a score using the new iOS 14+ API (GKLeaderboard.submitScore).
    // replace the leaderboard ID array with your own ID(s).
    func submitScore(_ score: Int) {
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: ["com.blackalgorithm.hopps.highscores"]
        ) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
            } else {
                print("Score submitted successfully!")
            }
        }
    }
    
    // presents the Game Center leaderboard for the specified ID.
    func showLeaderboard() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        // customize the leaderboardID, playerScope, timeScope as needed
        let gcVC = GKGameCenterViewController(
            leaderboardID: "com.blackalgorithm.hopps.highscores",
            playerScope: .global,
            timeScope: .allTime
        )
        gcVC.gameCenterDelegate = self
        rootVC.present(gcVC, animated: true)
    }
    
    // MARK: - GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
