//
//  FlowStepViewController.swift
//  Flowter
//
//  Created by Paulo Cesar Saito on 17/05/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import UIKit

//should call flowStep.next() or optionally flowStep.back() to continue the flow
public protocol Flowtable where Self: UIViewController {
    var flow: FlowStepInfo? { get set }

    func updateFlowStepViewController()
}

public extension Flowtable {
    func updateFlowStepViewController() { }
}
