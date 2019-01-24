//
//  EndFlowStep.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 13/08/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

public struct MakeEndStep<ContainerType: UIViewController> {
    public func makeEndFlow(with container: ContainerType) -> EndFlowStep<ContainerType> {
        return EndFlowStep<ContainerType>(with: container)
    }
}

public class EndFlowStep<ContainerType>: BaseFlowStepType {
    internal var endFlowAction: ( () -> Void)?
    
    internal var nextStep: BaseFlowStepType?
    internal let isLastStep: Bool = true
    internal let container: ContainerType
    
    internal init(with container: ContainerType) {
        self.container = container
    }
        
    //private methods
    internal func present(_ updating: Bool = false) {}
    
    internal func destroy() {
        endFlowAction = nil
        
        nextStep = nil
    }
    
    #if DEBUG
    deinit {
        print("Bye EndFlowStep")
    }
    #endif
}
