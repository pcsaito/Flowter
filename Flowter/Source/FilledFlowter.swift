//
//  FilledFlowter.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 25/01/19.
//  Copyright © 2019 Zazcar. All rights reserved.
//
import UIKit

public class FilledFlowter<ContainerType: UIViewController>: Flowter<ContainerType> {
    internal init(_ baseFlowter: Flowter<ContainerType>) {
        super.init(with: baseFlowter.flowContainer,
                   defaultPresentAction: baseFlowter.presentAction,
                   defaultDismissAction: baseFlowter.dismissAction)
        
        self.steps = baseFlowter.steps
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
        
        return FinishedFlowter(flowter: self)
    }
}
