//
//  FlowterTests.swift
//  FlowterTests
//
//  Created by Paulo Cesar Saito on 13/08/18.
//  Copyright © 2018 Zazcar. All rights reserved.
//
import Foundation
@testable import Flowter

class FlowterTestViewController: UIViewController, Flowtable {
    var flow: FlowStepInfo?
    
    var updateExpectation = XCTestExpectation(description: "update vc")
    func updateFlowStepViewController() {
        updateExpectation.fulfill()
    }
}

class FlowterTests: XCTestCase {
    let timeout: Double = 5
    
    var window: UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        return window
    }
    
    func testFlowStepAllocation() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "alloc vc")

        Flowter(with: flowContainer)
            .addStep {
                $0.make { () -> FlowterTestViewController in
                    expectation.fulfill()
                    return FlowterTestViewController()
                }
            }
            .addEndFlowStep { (container) in
                container.dismiss(animated: false)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testFlowStepCustomAllocation() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "alloc vc")
        
        Flowter(with: flowContainer)
            .addStep {
                $0.make { () -> FlowterTestViewController in
                    expectation.fulfill()
                    return FlowterTestViewController()
                }
            }
            .addEndFlowStep { (container) in
                container.dismiss(animated: false)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testFlowStart() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "start")
        
        Flowter(with: flowContainer)
            .addStep { $0.make { FlowterTestViewController() }}
            .addEndFlowStep { (container) in
                container.dismiss(animated: false)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false, completion: {
                    expectation.fulfill()
                })
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testFlowEnd() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "dismiss")
        
        let testingVC = FlowterTestViewController()
        
        Flowter(with: flowContainer)
            .addStep { $0.make { testingVC }}
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: {
                    expectation.fulfill()
                })
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        DispatchQueue.main.async {
            testingVC.flow?.next()
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testFlowEarlyEnd() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "early dismiss")
        
        let testingVC = FlowterTestViewController()
        
        Flowter(with: flowContainer)
            .addStep(with: { (stepFactory) -> FlowStep<FlowterTestViewController, UINavigationController> in
                let step = stepFactory.make(with: testingVC)
                
                step.setEndFlowAction({
                    flowContainer.dismiss(animated: false, completion: {
                        expectation.fulfill()
                    })
                })
                
                return step
            })
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: nil)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        DispatchQueue.main.async {
            testingVC.flow?.endFlow()
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testCustomPresentation() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "present")
        
        Flowter(with: flowContainer)
            .addStep(with: { (stepFactory) -> FlowStep<FlowterTestViewController, UINavigationController> in
                let step = stepFactory.make(with: FlowterTestViewController())
                
                step.setPresentAction({ (vc, container) in
                    container.pushViewController(vc, animated: false)
                    expectation.fulfill()
                })
                
                return step
            })
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: nil)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testCustomDefaultPresentation() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "present")
        
        let flow = Flowter(with: flowContainer, defaultPresentAction: { (vc, container) in
            container.pushViewController(vc, animated: false)
            expectation.fulfill()
        })
            
        flow.addStep { $0.make { FlowterTestViewController() }}
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: nil)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testCustomDismiss() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "custom dismiss")
        
        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestViewController()
        
        Flowter(with: flowContainer)
            .addStep { $0.make { testingVC1 }}
            .addStep(with: { (stepFactory) -> FlowStep<FlowterTestViewController, UINavigationController> in
                let step = stepFactory.make(with: testingVC2)
                
                step.setDismissAction({ (vc, container) in
                    container.popViewController(animated: false)
                    expectation.fulfill()
                })
                
                return step
            })
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: nil)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        DispatchQueue.main.async {
            testingVC1.flow?.next()
            DispatchQueue.main.async {
                testingVC2.flow?.back()
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testCustomDefaultDismiss() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "custom dismiss")
        
        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestViewController()
        
        let flow = Flowter(with: flowContainer, defaultDismissAction: { (vc, container) in
            container.popViewController(animated: false)
            expectation.fulfill()
        })

        flow.addStep { $0.make { testingVC1 }}
            .addStep { $0.make { testingVC2 }}
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: nil)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        DispatchQueue.main.async {
            testingVC1.flow?.next()
            DispatchQueue.main.async {
                testingVC2.flow?.back()
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testUpdateNext() {
        let flowContainer = UINavigationController()
        
        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestViewController()

        Flowter(with: flowContainer)
            .addStep { $0.make { testingVC1 }}
            .addStep { $0.make { testingVC2 }}
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: nil)
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        testingVC1.flow?.next(updating: true)

        wait(for: [testingVC2.updateExpectation], timeout: timeout)
    }
}
