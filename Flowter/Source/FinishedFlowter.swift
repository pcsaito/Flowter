//
//  FinishedFlowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 18/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

/// An FinishedFlowter containing a fully configured Flowter that can be started.
public struct FinishedFlowter<ContainerType> where ContainerType: UIViewController {
    internal let basedOn: FilledFlowter<ContainerType>
    
    /**
     Start the flow
     - Parameters:
         - flowPresentAction: An action closure the flow container presentation code.
     */
    public func startFlow(flowPresentAction: @escaping ( (_ flowContainer: ContainerType) -> Void)) {
        guard let step = basedOn.steps.first as? FlowStepType else { return }

        step.present()
        flowPresentAction(basedOn.flowContainer)
    }
}
