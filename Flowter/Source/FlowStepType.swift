//
//  FlowStepType.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 13/08/18.
//  Copyright © 2018 Zazcar. All rights reserved.
//

import Foundation

internal protocol FlowStepType {
    var isLastStep: Bool { get }
    var nextStep: FlowStepType? { get set }
    var endFlowAction: ( () -> Void)? { get set }
    
    func present(_ updating: Bool)
    func dismiss()
    
    func destroy()
}
