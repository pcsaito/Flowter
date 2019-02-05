//
//  FinishedFlowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 18/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

public struct FinishedFlowter<ContainerType> where ContainerType: UIViewController {
    internal let basedOn: FilledFlowter<ContainerType>

    public func startFlow(flowPresentAction: @escaping ( (_ flowContainer: ContainerType) -> Void)) {
        guard let step = basedOn.steps.first as? FlowStepType else { return }

        step.present(false, context: nil)
        flowPresentAction(basedOn.flowContainer)
    }
}
