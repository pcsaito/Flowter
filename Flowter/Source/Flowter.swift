//
//  Flowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 17/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit


/// Flowter is representation of the flow that holds all FlowtableViewController factories and presentation code,
/// and finishing (aka: providing dissmiss code) will return an FinishedFlowter ready to be presented.
public class Flowter<ContainerType> where ContainerType: UIViewController {
    
    /// Step factory type that hold lazy init code that allocate a Flowtable conforming object (your custom UIViewController generic type)
    public typealias StepFactoryType<T: Flowtable> = (_ stepFactory: MakeStep<T,ContainerType>) -> FlowStep<T,ContainerType>
    
    /// Function type of an presentation or dismiss actions
    public typealias StepActionType = ( (_ vc: UIViewController, _ container: ContainerType) -> Void)
    
    /// Function type of flow dismiss action
    public typealias EndFlowStepActionType = (_ container: ContainerType) -> Void
    
    /// The Container UIViewController that will present the flow
    public let flowContainer: ContainerType

    internal var steps: [BaseFlowStepType] = []
    internal let presentAction: StepActionType
    internal let dismissAction: StepActionType
    
    internal init(with container: ContainerType, defaultPresentAction: @escaping StepActionType,
                defaultDismissAction: @escaping StepActionType, flowSteps: [BaseFlowStepType])
    {
        steps = flowSteps
        flowContainer = container
        presentAction = defaultPresentAction
        dismissAction = defaultDismissAction
    }

    /**
     Initializes a new Flowter object with a container and optionally custom default presentation or dismiss code for all your steps.
     - Parameters:
         - container: The container that will present the flow
         - defaultPresentAction: A custom present action for all steps that don't customize it
         - defaultDismissAction: A custom dismiss action for all steps that don't customize it
     
     - Returns: A Flowter ready to be filled with steps and started.
     */
    public convenience init(with container: ContainerType,
                defaultPresentAction: StepActionType? = nil,
                defaultDismissAction: StepActionType? = nil)
    {
        self.init(with: container, defaultPresentAction: defaultPresentAction ?? Flowter<ContainerType>.defaultPresent(),
                  defaultDismissAction: defaultDismissAction ?? Flowter<ContainerType>.defaultDismiss(), flowSteps: [])
    }
    
    /**
     Add a step to Flowter object providing an StepFactory that will be allocated only before presenting.
     - Parameters:
         - with: A StepFactory that returns an FlowStep that represents the step
     
     - Returns: A FilledFlowter ready to be finished.
     */
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
    
    public func insert<ControllerType>(at index: Int, with: StepFactoryType<ControllerType>) {
        guard steps.count >= index else {
            addStep(with: with)
            return
        }
        
        let step = with(MakeStep<ControllerType,ContainerType>(container: flowContainer))

        if step.presentAction == nil {
            step.presentAction = presentAction
        }
        
        if index > 0 {
            var lastStepBeforeIndex = steps[index - 1]
            lastStepBeforeIndex.nextStep = step
        }

        let firstStepAfterIndex = steps[index]
        step.nextStep = firstStepAfterIndex

        steps.insert(step, at: index)
    }
    
    public func remove(at index: Int) {
        guard steps.count >= index else {
            return
        }
        
        if index > 0 {
            var lastStepBeforeIndex = steps[index - 1]
            let stepToRemove = steps[index]
            
            lastStepBeforeIndex.nextStep = stepToRemove.nextStep
        }

        steps.remove(at: index)
    }
    
    /**
     Add the end step to Flowter providing an EndFlowStepAction with the flow container dismiss code.
     - Parameters:
         - action: EndFlowStepActionType with the flow container dismiss code.
     
     - Returns: If the Flowter has one or more steps a FinishedFlowter ready to be started will be returned or nil when there is no steps.
     */
    public func addEndFlowStep(_ action: @escaping EndFlowStepActionType) -> FinishedFlowter<ContainerType>? {
        guard steps.count > 0 else {
            return nil
        }
        return FilledFlowter(basedOn: self).addEndFlowStep(action)
    }
    
    #if DEBUG
    deinit {
        print("Bye Flowter: \(self)")
    }
    #endif
}

extension Flowter  {
    //private methods
    internal func clearSteps() {
        steps.forEach { $0.destroy() }
        steps.removeAll()
    }

    internal func clearNavigation() {
        guard let navigationContainer = self.flowContainer as? UINavigationController else { return }
        
        //fixme
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigationContainer.viewControllers = [UIViewController]()
        }
    }
    
    internal static func defaultPresent() -> StepActionType {
        return { (vc, container) in
            if let navContainer = container as? UINavigationController {
                guard navContainer.viewControllers.contains(vc) == false else { return }
                let newViewControllers = navContainer.viewControllers + [vc]
                navContainer.setViewControllers(newViewControllers, animated: true)
            } else {
                container.addChild(vc)
                container.view.addSubview(vc.view)
                vc.didMove(toParent: container)
            }
        }
    }
    
    internal static func defaultDismiss() -> StepActionType {
        return { (vc, container) in
            if let navContainer = container as? UINavigationController {
                navContainer.popViewController(animated: true)
            } else {
                vc.removeFromParent()
                vc.view.removeFromSuperview()
                vc.didMove(toParent: nil)
            }
        }
    }
}
