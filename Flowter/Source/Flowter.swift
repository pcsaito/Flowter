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
    
    internal var steps = [BaseFlowStepType]()
    
    internal let presentAction: DefaultStepActionType
    internal let dismissAction: DefaultStepActionType
    
    public let flowContainer: ContainerType

    public init(with container: ContainerType,
                defaultPresentAction: @escaping  DefaultStepActionType = Flowter<ContainerType>.defaultPresent(),
                defaultDismissAction: @escaping  DefaultStepActionType = Flowter<ContainerType>.defaultDismiss())
    {
        flowContainer = container
        presentAction = defaultPresentAction
        dismissAction = defaultDismissAction
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
        
        return FilledFlowter(self)
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

public class FilledFlowter<ContainerType: UIViewController>: Flowter<ContainerType> {
    init(_ baseFlowter: Flowter<ContainerType>) {
        super.init(with: baseFlowter.flowContainer,
                   defaultPresentAction: baseFlowter.presentAction,
                   defaultDismissAction: baseFlowter.dismissAction)
        
        self.steps = baseFlowter.steps
    }

    public func addEndFlowStep(_ action: @escaping EndFlowStepActionType) -> FinishedFlowter<ContainerType> {
        let endStep = MakeEndStep<ContainerType>().makeEndFlow(with: flowContainer)
        
        var lastStep = steps.last
        lastStep?.nextStep = endStep
        steps.append(endStep)
        
        endStep.endFlowAction = { [weak self] in
            guard let container = self?.flowContainer else { return }
            action(container)
        }
        
        if let endFlowAction = endStep.endFlowAction {
            steps.forEach { (eachStep) in
                var mutableStep = eachStep
                var endAction = endFlowAction
                if let definedEndStep = mutableStep.endFlowAction {
                    endAction = definedEndStep
                }
                
                mutableStep.endFlowAction = {
                    endAction()
                    self.clearSteps()
                    self.clearNavigation()
                }
            }
        }
        
        return FinishedFlowter(flowter: self)
    }
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
