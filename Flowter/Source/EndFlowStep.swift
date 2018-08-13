//
//  EndFlowStep.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 13/08/18.
//  Copyright © 2018 Zazcar. All rights reserved.
//

import Foundation

public struct MakeEndStep<ContainerType: UIViewController> {
    public func makeEndFlow() -> EndFlowStep<ContainerType> {
        return EndFlowStep<ContainerType>()
    }
}

public class EndFlowStep<ContainerType>: FlowStepType {
    internal var endFlowAction: ( () -> Void)?
    
    internal var isLastStep: Bool = false
    internal var nextStep: FlowStepType?
    internal var container: ContainerType?
        
    //private methods
    internal func present(_ updating: Bool = false) {}
    internal func dismiss() {}
    
    internal func destroy() {
        endFlowAction = nil
        
        container = nil
        nextStep = nil
    }
    
    #if DEBUG
    deinit {
        print("Bye EndFlowStep")
    }
    #endif
}
