//
//  FlowStepInfo.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 18/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import Foundation

// A proxy to Flowtable UIViewControllers interact with the flow.
public struct FlowStepInfo {
    internal var flowStep: BaseFlowStepType

    /**
     Present the next step on the flow
     - Parameters:
         - context: An optional context object of Any? type
     */
    public func next(context: Any? = nil) {
        guard let nextStep = flowStep.nextStep as? FlowStepType else {
            flowStep.nextStep?.endFlowAction?()
            return
        }
        nextStep.present(with: context)
    }
    
    /// Perform the the dismiss code
    public func back() {
        (flowStep as? FlowStepType)?.dismiss()
    }

    /// Ends the flow prematurelly calling its EndFlowStepAction
    public func endFlow() {
        flowStep.endFlowAction?()
    }
}
