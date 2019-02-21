//
//  EndFlowStep.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 13/08/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

/// Proxy that gets a container and returns a EndFlowStep object
public struct MakeEndStep<ContainerType: UIViewController> {
    
    /**
     Make an EndFlowStep based on the container
     - Parameters:
         - container: The flow container
     
     - Returns: A EndFlowStep with the container to be dismissed
     */
    public func makeEndFlow(with container: ContainerType) -> EndFlowStep<ContainerType> {
        return EndFlowStep<ContainerType>(with: container)
    }
}

/// A EndFlowStep contains just the container to be dismissed
public class EndFlowStep<ContainerType>: BaseFlowStepType {
    internal var endFlowAction: ( () -> Void)?
    
    internal var nextStep: BaseFlowStepType?
    internal let container: ContainerType
    
    internal init(with container: ContainerType) {
        self.container = container
    }
    
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
