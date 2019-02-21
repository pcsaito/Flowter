//
//  FlowStepType.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 13/08/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import Foundation

internal protocol BaseFlowStepType {
    var nextStep: BaseFlowStepType? { get set }
    var endFlowAction: ( () -> Void)? { get set }

    func destroy()
}

internal protocol FlowStepType: BaseFlowStepType {
    func present(with context: Any?)
    func dismiss()
}

internal extension FlowStepType {    
    func present() {
        present(with: nil)
    }
}
