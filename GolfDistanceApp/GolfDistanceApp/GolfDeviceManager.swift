
//
//  GolfDeviceManager.swift
//  GolfDistanceApp
//
//  Created by Conor Griffiths on 05/03/2025.
//

import MetaWearablesSDK

class GolfDeviceManager: NSObject, MWSDKDeviceManagerListener {
    func deviceDidDiscover(_ device: MWSDKDevice) {
        
    }
    
    func deviceDidForget(_ device: MWSDKDevice) {
        
    }
    
    func didEncounterError(_ error: any Error) {
        
    }
    
    static let sharedInstance = GolfDeviceManager()
    
    // ✅ Implement required methods for MWSDKDeviceManagerListener
    func deviceManagerRequestedDeleteRegistration() {
        NSLog("Device Manager Requested Delete Registration")
    }

    func stateDidUpdate(_ newState: MWSDKState) {
        NSLog("Device Manager State Updated: \(newState)")
    }
}
// Extend GolfDeviceManager to conform to MWSDKAIActionsDelegate
extension GolfDeviceManager: MWSDKAIActionsDelegate {
    
    // 🔹 Process AI Action when received
    func processAIAction(action: String, payload: String, aiAction: MWSDKAIAction) {
        if let data = payload.data(using: .utf8) {
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                LocationManager.sharedInstance.calculateDistances()
                aiAction.sendResponse("{\"result_code\":\"success\"}")
            } catch {
                NSLog("Error handling AIAction response")
            }
        }
    }

    // Required function 1: Handle AI Action session changes
    func aiActionsSession(_ session: MWSDKAIActionSession, didChange state: MWSDKAIActionsState, with reason: MWSDKAIActionsStateChangeReason) {
        NSLog("AI Actions session changed: \(reason.reasonString)")
    }

    // Required function 2: Handle errors in AI Actions
    func aiActionsSession(_ session: MWSDKAIActionSession, didReceiveError error: Error) {
        NSLog("AI Actions session error: \(error.localizedDescription)")
    }

    // Required function 3: Handle AI Actions received from the session
    func aiActionsSession(_ session: MWSDKAIActionSession, didReceive aiAction: MWSDKAIAction) {
        DispatchQueue.main.async {
            NSLog("AI Actions session received message requestID \(aiAction.requestID) action \(aiAction.action), payload \(aiAction.clientData)")

            // Call processAIAction for handling
            self.processAIAction(action: aiAction.action, payload: aiAction.clientData, aiAction: aiAction)
        }
    }
}
