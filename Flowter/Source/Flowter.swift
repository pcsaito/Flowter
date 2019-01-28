//
//  Flowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 17/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

public class Flowter<ContainerType> where ContainerType: UIViewController {
    public typealias StepFactoryType<T: Flowtable> = (_ stepFactory: MakeStep<T,ContainerType>) -> FlowStep<T,ContainerType>
    public typealias DefaultStepActionType = ( (_ vc: UIViewController, _ container: ContainerType) -> Void)
    public typealias EndFlowStepActionType = (_ container: ContainerType) -> Void
    
    public let flowContainer: ContainerType

    internal var steps: [BaseFlowStepType]
    internal let presentAction: DefaultStepActionType
    internal let dismissAction: DefaultStepActionType
    
    internal init(with container: ContainerType, defaultPresentAction: @escaping DefaultStepActionType,
                defaultDismissAction: @escaping DefaultStepActionType, flowSteps: [BaseFlowStepType])
    {
        steps = flowSteps
        flowContainer = container
        presentAction = defaultPresentAction
        dismissAction = defaultDismissAction
    }

    public convenience init(with container: ContainerType,
                defaultPresentAction: @escaping DefaultStepActionType = Flowter<ContainerType>.defaultPresent(),
                defaultDismissAction: @escaping DefaultStepActionType = Flowter<ContainerType>.defaultDismiss())
    {
        self.init(with: container, defaultPresentAction: defaultPresentAction,
                  defaultDismissAction: defaultDismissAction, flowSteps: [])
    }
    
    @discardableResult
    public func addStep<ControllerType>(with: StepFactoryType<ControllerType>) -> FilledFlowter<ContainerType> {
        let step = with(MakeStep<ControllerType,ContainerType>(container: flowContainer))
        
        var lastStep = steps.last
        lastStep?.nextStep = step
        steps.append(step)
        
        if step.endFlowAction == nil && step.presentAction == nil {
            step.presentAction = presentAction
        }
        
        if steps.count != 0 && step.dismissAction == nil {
            step.dismissAction = dismissAction
        }
        
        return FilledFlowter(basedOn: self)
    }
    
    public func addEndFlowStep(_ action: @escaping EndFlowStepActionType) -> FinishedFlowter<ContainerType>? {
        guard steps.count > 0 else {
            return nil
        }
        return FilledFlowter(basedOn: self).addEndFlowStep(action)
    }
    
    //private methods
    internal func clearNavigation() {
        guard let navigationContainer = self.flowContainer as? UINavigationController else { return }
        
        //fixme
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigationContainer.viewControllers = [UIViewController]()
        }
    }
    
    internal func clearSteps() {
        steps.forEach { $0.destroy() }
        steps.removeAll()
    }
    
    #if DEBUG
    deinit {
        print("Bye Flowter: \(self)")
    }
    #endif
}

//for convenience initializers usage
extension Flowter {
    public static func defaultPresent() -> DefaultStepActionType {
        return { (vc, container) in
            if let navContainer = container as? UINavigationController {
                guard navContainer.viewControllers.contains(vc) == false else { return }
                let newViewControllers = navContainer.viewControllers + [vc]
                navContainer.setViewControllers(newViewControllers, animated: true)
            } else {
                container.addChild(vc)
                container.view.addSubview(vc.view)
            }
        }
    }

    public static func defaultDismiss() -> DefaultStepActionType {
        return { (vc, container) in
            if let navContainer = container as? UINavigationController {
                navContainer.popViewController(animated: true)
            } else {
                vc.removeFromParent()
                vc.view.removeFromSuperview()
            }
        }
    }
}
