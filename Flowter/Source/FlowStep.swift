//
//  FlowStep.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 17/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import Foundation

public struct MakeStep<ControllerType: Flowtable, ContainerType: UIViewController> {
    let container: ContainerType
    
    public func make(withFactoryClosure: @escaping () -> ControllerType) -> FlowStep<ControllerType,ContainerType> {
        return FlowStep<ControllerType,ContainerType>(with: withFactoryClosure, on: container)
    }

    public func make(with controller: @autoclosure @escaping () -> ControllerType) -> FlowStep<ControllerType,ContainerType> {
        return make(withFactoryClosure: controller)
    }
}

public class FlowStep<ControllerType: Flowtable, ContainerType>: FlowStepType {
    public typealias StepActionType = ( (_ vc: ControllerType, _ container: ContainerType) -> Void)
    public typealias ViewControllerFactoryType = () -> ControllerType

    private let viewControllerFactory: ViewControllerFactoryType

    internal var presentAction: StepActionType?
    internal var dismissAction: StepActionType?
    internal var endFlowAction: ( () -> Void)?

    internal var nextStep: BaseFlowStepType?
    internal let isLastStep: Bool = false
    internal let container: ContainerType

    lazy var viewController: ControllerType = { [unowned self] in
        self.viewControllerFactory()
    }()

    public init(with factory: @escaping ViewControllerFactoryType, on container: ContainerType) {
        self.viewControllerFactory = factory
        self.container = container
    }

    public func setPresentAction(_ action: @escaping StepActionType) {
        presentAction = action
    }

    public func setDismissAction(_ action: @escaping StepActionType) {
        dismissAction = action
    }

    public func setEndFlowAction(_ action: @escaping ( () -> Void)) {
        endFlowAction = action
    }

    //private methods
    internal func present(_ updating: Bool = false) {
        viewController.flow = FlowStepInfo(flowStep: self)
        if updating {
            viewController.updateFlowStepViewController()
        }

        presentAction?(viewController, container)
    }

    internal func dismiss() {
        dismissAction?(viewController, container)
    }

    internal func destroy() {
        presentAction = nil
        dismissAction = nil
        endFlowAction = nil

        nextStep = nil

        if !isLastStep {
            viewController.flow = nil
        }
    }

    #if DEBUG
    deinit {
        print("Bye FlowStep: \(!isLastStep ? self.viewController.description : "EndStep")")
    }
    #endif
}
