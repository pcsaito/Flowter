//
//  FilledFlowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 25/01/19.
//  Copyright © 2019 Zazcar. All rights reserved.
//
import UIKit

public class FilledFlowter<ContainerType: UIViewController>: Flowter<ContainerType> {
    internal init(basedOn flowter: Flowter<ContainerType>) {
        super.init(with: flowter.flowContainer, defaultPresentAction: flowter.presentAction,
                   defaultDismissAction: flowter.dismissAction, flowSteps: flowter.steps)
    }
    
    public override func addEndFlowStep(_ action: @escaping EndFlowStepActionType) -> FinishedFlowter<ContainerType> {
        let endStep = MakeEndStep<ContainerType>().makeEndFlow(with: flowContainer)
        
        var lastStep = steps.last
        lastStep?.nextStep = endStep
        steps.append(endStep)
        
        endStep.endFlowAction = { [weak self] in
            guard let container = self?.flowContainer else { return }
            action(container)
        }
        
        if let endFlowAction = endStep.endFlowAction {
            steps.forEach { (eachStep) in
                var mutableStep = eachStep
                var endAction = endFlowAction
                if let definedEndStep = mutableStep.endFlowAction {
                    endAction = definedEndStep
                }
                
                mutableStep.endFlowAction = {
                    endAction()
                    self.clearSteps()
                    self.clearNavigation()
                }
            }
        }
        
        return FinishedFlowter(basedOn: self)
    }
}
