/* GolfDeviceManager.swift
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

import MetaWearablesSDK

class GolfDeviceManager: NSObject {
  static let sharedInstance = GolfDeviceManager()
  private var discoveredDevices: Set<MWSDKDevice> = []
  private var aiActionSessions: Set<MWSDKAIActionSession> = []
}

extension GolfDeviceManager: MWSDKDeviceManagerListener {
  func deviceDidDiscover (_ device: MWSDKDevice ) {
    NSLog("Discovered Device \(String(describing: device))")
    NSLog("Device Serial \(String(describing: device.serialNumberSuffix))")
    discoveredDevices.insert(device)

    // Listen to device connection
    device.add(self)
  }

  func deviceDidForget (_ device: MWSDKDevice ) {
    NSLog("Forgot Device \(String(describing: device))")
    self.discoveredDevices.remove(device)
  }

  func deviceManagerRequestedDeleteRegistration() {
    NSLog("Device Manager Requested Delete Registration")
  }

  func stateDidUpdate (_ newState: MWSDKState ) {
    switch newState {
    default:
      NSLog("State Did Update \(String(describing: newState))")
    }
  }

  func didEncounterError(_ error: Error) {
    NSLog("Did Encounter Error \(String(describing: error))")
  }
}

extension GolfDeviceManager: MWSDKDeviceListener {
  func deviceDidConnect(_ device: MWSDKDevice) {
    NSLog("Device Did Connect \(String(describing: device))")
    self.aiActionSessions.insert(MWSDKAIActionSession(device: device, delegate: self, delegateQueue: DispatchQueue.global()))
  }

  func deviceDidDisconnect(_ device: MWSDKDevice, withError error: any Error) {
    NSLog("Device Did Disconnect \(String(describing: device))")
    self.discoveredDevices.remove(device)
  }

  func deviceDidFail(toConnect device: MWSDKDevice, withError error: any Error) {
    NSLog("Device Did Fail \(String(describing: device))")
  }
}

extension GolfDeviceManager: MWSDKAIActionsDelegate {
  func aiActionsSession(_ session: MWSDKAIActionSession, didChange state: MWSDKAIActionsState, with reason: MWSDKAIActionsStateChangeReason) {
    NSLog("AIActions state changed: \(reason.reasonString)")
    if state == MWSDKAIActionsState.AIActionsTerminated {
      // remove the session
      self.aiActionSessions.remove(session)
    }
    /* Update the ui that the state has changed

     DispatchQueue.main.async {
     **UI Change**
     }

     */
  }

  func aiActionsSession(_ session: MWSDKAIActionSession, didReceiveError error: any Error) {
    NSLog("AI Actions session error \(error)")
  }

  func processAIAction(action: String, payload: String, aiAction: MWSDKAIAction) {
    // The "food_calories" parameter's name and data type should match your configuration in the Developer Center project.
    // For any changes or additions, you can use Developer Center by navigating to Project > Functions and using the Generate code button.
    // This will generate code you can copy into your Xcode project.
    if let data = payload.data(using: .utf8) {
      do {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          LocationManager.sharedInstance.calculateDistances()
          aiAction.sendResponse("{\"result_code\":\"success\"}")
      } catch {
        NSLog("Error handling aiAction response")
      }
    }
  }

  func aiActionsSession(_ session: MWSDKAIActionSession, didReceive aiAction: MWSDKAIAction) {
    DispatchQueue.main.async {
      NSLog("AI Actions session received message requestID \(aiAction.requestID) action \(aiAction.action), payload \(aiAction.clientData)")

      self.processAIAction(action: aiAction.action, payload: aiAction.clientData, aiAction: aiAction)
    }
  }
}

