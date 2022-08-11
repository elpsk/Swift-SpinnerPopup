//
//  AlertDialog.swift
//  AlertPopup
//
//  Created by Pasca Alberto, IT on 11/08/22.
//

import UIKit

class SpinnerViewController: UIViewController {

    override func loadView() {
        super.loadView()
        
        let spinner = UIView(frame: .zero)
        spinner.backgroundColor = .white
        spinner.layer.cornerRadius = 18
        spinner.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        spinner.layer.shadowOffset = CGSize(width: 0, height: 0)
        spinner.layer.shadowRadius = 6
        spinner.layer.shadowOpacity = 0.1

        let activity = UIActivityIndicatorView(frame: spinner.bounds)
        activity.color = .red
        activity.style = .large
        activity.startAnimating()
        spinner.addSubview(activity)

        self.view.addSubview( spinner )
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        let horizontalContainerConstraint = NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let verticalContainerConstraint = NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        let widthContainerConstraint = NSLayoutConstraint(item: spinner, attribute: .width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        let heightContainerConstraint = NSLayoutConstraint(item: spinner, attribute: .height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        NSLayoutConstraint.activate([
            horizontalContainerConstraint,
            verticalContainerConstraint,
            widthContainerConstraint,
            heightContainerConstraint
        ])

        activity.translatesAutoresizingMaskIntoConstraints = false
        let horizontalActivityConstraint = NSLayoutConstraint(item: activity, attribute: .centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let verticalActivityConstraint = NSLayoutConstraint(item: activity, attribute: .centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            horizontalActivityConstraint,
            verticalActivityConstraint
        ])
    }

}

class SpinnerManager {
    static let shared: SpinnerManager = { SpinnerManager() }()
    
    private var blankWindow: UIWindow?
    private var timeoutCallback: (() -> Void)?
    private var timeoutHandlerTimer: Timer?
    private var blurEffectView: CustomVisualEffectView?

    private lazy var spinnerVC: SpinnerViewController = SpinnerViewController()

    func showAlert(
        blurBackground: Bool = false,
        autodismissTimeout: Double = 30.0,
        timeoutCallback: (() -> Void)? = nil
    ) {
        blurEffectView?.removeFromSuperview()

        if isVisible {
            if autodismissTimeout > 0 {
                timeoutHandlerTimer?.invalidate()
                timeoutHandlerTimer = Timer.scheduledTimer(
                    timeInterval: autodismissTimeout, target: self, selector: #selector(dispatchTimeoutHandlerAndDismiss), userInfo: nil, repeats: false
                )
            }
            return
        }
        
        if autodismissTimeout > 0 {
            self.timeoutCallback = timeoutCallback
        }
       
        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            blankWindow = UIWindow(windowScene: currentWindowScene)
            blankWindow?.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            blankWindow?.windowLevel = .alert
            blankWindow?.rootViewController = spinnerVC

            if blurBackground {
                blurEffectView = CustomVisualEffectView(effect: UIBlurEffect(style: .dark), intensity: 0.0)
                blurEffectView?.frame = blankWindow!.rootViewController!.view.bounds
                blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                UIView.animate(withDuration: 0.25) {
                    self.blurEffectView!.customIntensity = 0.15
                }
                
                blankWindow?.rootViewController?.view.insertSubview(blurEffectView!, at: 0)
            }

            blankWindow?.makeKeyAndVisible()
            
            if autodismissTimeout > 0 {
                timeoutHandlerTimer?.invalidate()
                timeoutHandlerTimer = Timer.scheduledTimer(
                    timeInterval: autodismissTimeout, target: self, selector: #selector(dispatchTimeoutHandlerAndDismiss), userInfo: nil, repeats: false
                )
            }
        }
    }
    
    @objc private func dispatchTimeoutHandlerAndDismiss() {
        timeoutCallback?()
        self.dismiss()
    }
    
    func dismiss() {
        timeoutHandlerTimer?.invalidate()
        timeoutHandlerTimer = nil
        timeoutCallback = nil
        blankWindow = nil
    }
    
    var isVisible: Bool {
        get {
            (UIApplication.topMostKeyWindow?.rootViewController as? SpinnerViewController) != nil
        }
    }
}

extension UIApplication {
    /// The top most keyWindow
    static var topMostKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .flatMap({ $0 })?.windows
            .first(where: { $0.isKeyWindow })
    }
}

class CustomVisualEffectView: UIVisualEffectView {
    private let theEffect: UIVisualEffect
    var customIntensity: CGFloat
    private var animator: UIViewPropertyAnimator?

    init(effect: UIVisualEffect, intensity: CGFloat) {
        theEffect = effect
        customIntensity = intensity
        super.init(effect: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { nil }
    
    deinit { animator?.stopAnimation(true) }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            effect = theEffect
        }
        animator?.fractionComplete = customIntensity
    }
}
