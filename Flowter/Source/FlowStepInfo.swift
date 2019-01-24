//
//  FlowStepInfo.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 18/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import Foundation

public struct FlowStepInfo {
    internal var flowStep: BaseFlowStepType

    public func next(updating: Bool = false) {
        guard let nextStep = flowStep.nextStep, !nextStep.isLastStep else {
            flowStep.nextStep?.endFlowAction?()
            return
        }

        nextStep.present(updating)
    }

    public func back() {
        (flowStep as? FlowStepType)?.dismiss()
    }

    public func endFlow() {
        flowStep.endFlowAction?()
    }
}
