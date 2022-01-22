//
//  ARViewController.swift
//  TinyToyTank
//
//  Created by Aye Chan on 1/22/22.
//

import UIKit
import SnapKit
import RealityKit

class ARViewController: UIViewController {
    private let arView = ARView()
    private let helpButton = UIButton()
    
    private var tankAnchor: TinyToyTank._TinyToyTank?
    private var isAnimationPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupArView()
        setupHelpButton()
        setupGestures()
    }
    
    private func setupArView() {
        view.addSubview(arView)
        arView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tankAnchor = try? TinyToyTank.load_TinyToyTank()
        guard let anchor = tankAnchor else { return }
        tankAnchor?.cannon?.setParent(anchor.tank, preservingWorldTransform: true)
        tankAnchor?.actions.actionComplete.onAction = { [weak self] _ in
            self?.isAnimationPlaying = false
        }
        arView.scene.anchors.append(anchor)
    }
    
    private func setupHelpButton() {
        view.addSubview(helpButton)
        helpButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(view.layoutMarginsGuide)
        }
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Info"
        configuration.image = UIImage(systemName: "info.circle")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 5
        configuration.buttonSize = .medium
        configuration.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        configuration.baseBackgroundColor = .clear
        configuration.baseForegroundColor = .label
        helpButton.configuration = configuration
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style:
                                                            UIBlurEffect.Style.regular))
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 10
        blur.layer.masksToBounds = true
        helpButton.insertSubview(blur, at: 0)
        blur.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        helpButton.addTarget(self, action: #selector(handleClick(_:)), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        downSwipe.direction = .down
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = 2
        let doubleRightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleDoubleSwipe(_:)))
        doubleRightSwipe.direction = .right
        doubleRightSwipe.numberOfTouchesRequired = 2
        let doubleLeftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleDoubleSwipe(_:)))
        doubleLeftSwipe.direction = .left
        doubleLeftSwipe.numberOfTouchesRequired = 2
        
        arView.addGestureRecognizer(rightSwipe)
        arView.addGestureRecognizer(leftSwipe)
        arView.addGestureRecognizer(downSwipe)
        arView.addGestureRecognizer(tap)
        arView.addGestureRecognizer(doubleRightSwipe)
        arView.addGestureRecognizer(doubleLeftSwipe)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if isAnimationPlaying {
            return
        } else {
            isAnimationPlaying = true
        }
        switch gesture.direction {
        case .down: tankAnchor?.notifications.tankForward.post()
        case .left: tankAnchor?.notifications.tankLeft.post()
        case .right: tankAnchor?.notifications.tankRight.post()
        default: break
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if isAnimationPlaying {
            return
        } else {
            isAnimationPlaying = true
        }
        tankAnchor?.notifications.cannonFire.post()
    }
    
    @objc func handleDoubleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if isAnimationPlaying {
            return
        } else {
            isAnimationPlaying = true
        }
        switch gesture.direction {
        case .right: tankAnchor?.notifications.turretRight.post()
        case .left: tankAnchor?.notifications.turretLeft.post()
        default: break
        }
    }
    
    @objc func handleClick(_ button: UIButton) {
        let alert = UIAlertController(title: "Info", message: """
        Double Tap: Cannon Fire
        Two Fingers Swipe Right: Turret Right
        Two Fingers Swipe Left: Turret Left
        Swipe Right: Tank Right
        Swipe Left: Tank Left
        Swipe Down: Tank Forward
        """, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

