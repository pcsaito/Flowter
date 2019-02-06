//
//  FlowterTests.swift
//  FlowterTests
//
//  Created by Paulo Cesar Saito on 13/08/18.
//  Copyright 2018 Zazcar. All rights reserved.
//
import XCTest
@testable import Flowter

struct TestContext: Equatable {
    let name: String, age: Int
}

class FlowterTestViewController: UIViewController, Flowtable {
    var flow: FlowStepInfo?
}

class FlowterTestUpdatingViewController: UIViewController, Flowtable {
    var flow: FlowStepInfo?, context: Any?
    
    var updateExpectation = XCTestExpectation(description: "update vc")
    func updateFlowtableViewController(with context: Any?) {
        self.context = context
        updateExpectation.fulfill()
    }
}

let testTimeout: Double = 5
class FlowterTests: XCTestCase {
    
    var window: UIWindow {
        let window = UIApplication.shared.keyWindow ?? UIWindow(frame: UIScreen.main.bounds)
        let root = UIViewController()

        root.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
        
        window.rootViewController = root
        window.makeKeyAndVisible()
        
        root.endAppearanceTransition() // Triggers viewDidAppear

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
        
        wait(for: [expectation], timeout: testTimeout)
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
        
        wait(for: [expectation], timeout: testTimeout)
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
        
        wait(for: [expectation], timeout: testTimeout)
    }
    
    func testFlowEnd() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "dismiss")
        
        let testingVC = FlowterTestViewController()
        
        let flowter = Flowter(with: flowContainer)
        flowter.addStep { $0.make { testingVC }}
        
        let filledFlowter = flowter.addEndFlowStep { (container) in
            container.dismiss(animated: false, completion: {
                expectation.fulfill()
            })
        }
            
        filledFlowter?.startFlow { (container) in
            let rootVC = self.window.rootViewController
            rootVC!.present(container, animated: false)
        }
        
        DispatchQueue.main.async {
            testingVC.flow?.next()
        }
        
        wait(for: [expectation], timeout: testTimeout)
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
        
        wait(for: [expectation], timeout: testTimeout)
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
        
        wait(for: [expectation], timeout: testTimeout)
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
        
        wait(for: [expectation], timeout: testTimeout)
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
        
        testingVC1.flow?.next()
        testingVC2.flow?.back()
        
        wait(for: [expectation], timeout: testTimeout)
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
        
        testingVC1.flow?.next()
        testingVC2.flow?.back()
        
        wait(for: [expectation], timeout: testTimeout)
    }
    
    func testUpdateNext() {
        let flowContainer = UINavigationController()
        
        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestUpdatingViewController()

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
        
        testingVC1.flow?.next()

        wait(for: [testingVC2.updateExpectation], timeout: testTimeout)
    }
    
    func testPassingDataToNextStep() {
        let flowContainer = UINavigationController()
        
        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestUpdatingViewController()
        
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
        
        let testingVC1Context = TestContext(name: "Fernando", age: 30)
        testingVC1.flow?.next(context: testingVC1Context)
        
        XCTAssertEqual(testingVC1Context, testingVC2.context as? TestContext)
    }
    
    func testLosingDataSentToNextStep() {
        let flowContainer = UINavigationController()
        let expectation = XCTestExpectation(description: "start")
        
        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestViewController()

        Flowter(with: flowContainer)
            .addStep { $0.make { testingVC1 }}
            .addStep { $0.make { testingVC2 }}
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: {
                    expectation.fulfill()
                })
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        testingVC1.flow?.next(context: "This string shall be lost") //And this should be logged
        testingVC2.flow?.next()
        
        wait(for: [expectation], timeout: testTimeout) //Should lose context without side effects
    }
    
    func testEmptyFlow() {
        let flowContainer = UINavigationController()
        
        let flowter = Flowter(with: flowContainer)
            .addEndFlowStep({ (container) in
                container.dismiss(animated: false, completion: nil)
            })
        
        XCTAssertNil(flowter, "ending an empty flowter should return nil")
    }
        
    func testUIViewControllerContainerFlow() {
        let flowContainer = UIViewController()
        
        let showExpectation = XCTestExpectation(description: "showExpectation")
        let hideExpectation = XCTestExpectation(description: "hideExpectation")
        let closeFlowExpectation = XCTestExpectation(description: "closeFlowExpectation")

        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestViewController()
        let testingVC3 = FlowterTestViewController()

        Flowter(with: flowContainer)
            .addStep { $0.make(with: testingVC1) }
            .addStep(with: { (stepFactory) -> FlowStep<FlowterTestViewController, UIViewController> in
                let step = stepFactory.make(with: testingVC2)
                
                step.setPresentAction({ (vc, container) in
                    container.addChild(vc)
                    container.view.addSubview(vc.view)
                    showExpectation.fulfill()
                })
                
                step.setDismissAction({ (vc, container) in
                    vc.removeFromParent()
                    vc.view.removeFromSuperview()
                    hideExpectation.fulfill()
                })
                
                return step
            })
            .addStep { $0.make(with: testingVC3) }
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: {
                    closeFlowExpectation.fulfill()
                })
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        //trigger testingVC2 default presentation and dismiss
        testingVC1.flow?.next()
        testingVC2.flow?.back()

        //trigger testingVC3 default presentation and dismiss
        testingVC1.flow?.next()
        testingVC2.flow?.next()
        testingVC3.flow?.back()
        
        //trigger close flow
        testingVC2.flow?.next()
        testingVC3.flow?.next()

        wait(for: [showExpectation, hideExpectation, closeFlowExpectation], timeout: testTimeout)
    }
    
    func testDoubleNextCalling() {
        let flowContainer = UINavigationController()
        
        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestViewController()
        let postDismissExpectation = XCTestExpectation(description: "end expectation")
        
        Flowter(with: flowContainer)
            .addStep { $0.make { testingVC1 }}
            .addStep { $0.make { testingVC2 }}
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        postDismissExpectation.fulfill()
                    })
                })
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        testingVC1.flow?.next()
        testingVC1.flow?.next()
        testingVC2.flow?.next()
        
        wait(for: [postDismissExpectation], timeout: testTimeout)
    }
    
    func testDoubleNextCallingWithDelay() {
        let flowContainer = UINavigationController()
        
        let testingVC1 = FlowterTestViewController()
        let testingVC2 = FlowterTestViewController()
        let postDismissExpectation = XCTestExpectation(description: "end expectation")
        
        let presentExpectation = XCTestExpectation(description: "present expectation")
        presentExpectation.assertForOverFulfill = true
        presentExpectation.expectedFulfillmentCount = 1
        
        Flowter(with: flowContainer)
            .addStep { $0.make { testingVC1 }}
            .addStep { $0.make { testingVC2 }}
            .addEndFlowStep { (container) in
                container.dismiss(animated: false, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        postDismissExpectation.fulfill()
                    })
                })
            }
            .startFlow { (container) in
                let rootVC = self.window.rootViewController
                rootVC!.present(container, animated: false)
        }
        
        testingVC1.flow?.next()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            testingVC1.flow?.next()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                testingVC2.flow?.next()
            }
        }
        wait(for: [postDismissExpectation], timeout: testTimeout)
    }
}
