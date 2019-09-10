//
//  HeartwitchView.swift
//  Heartwitch-watchOS-app WatchKit Extension
//
//  Created by Leo Dion on 9/3/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI
import Heartwitch
import AuthenticationServices

struct AppleLoginButton: WKInterfaceObjectRepresentable {

    typealias WKInterfaceObjectRepresentable = WKInterfaceObjectRepresentableContext<AppleLoginButton>

    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceAuthorizationAppleIDButton, context: WKInterfaceObjectRepresentableContext<AppleLoginButton>) {
        // No code required
    }

    class Coordinator: NSObject, ASAuthorizationControllerDelegate {

        @objc func buttonPressed() {

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Verify the user
              debugPrint(appleIDCredential)
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // Handle error.
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<AppleLoginButton>) -> WKInterfaceAuthorizationAppleIDButton {
        return WKInterfaceAuthorizationAppleIDButton(target: context.coordinator, action: #selector(Coordinator.buttonPressed))
    }

}

struct HeartwitchView: View {
  @EnvironmentObject var object : HeartwitchObject
  
  var body: some View {
    ZStack{
      ZStack{
        textView
        beginMonitoringView
        heartRateView
      }
    }
  }
  
  var textView : some View {
        let hasNoConnection : Void?
    if self.object.fullIdentifier == nil && self.object.timer == nil {
         hasNoConnection = Void()
        } else {
          hasNoConnection = nil
        }
        return hasNoConnection.map{
          TextField("Enter Workout Id", text: $object.shortID)
             
        }
  }
  
  
  var beginMonitoringView : some View {
    let identifier : String?
    if self.object.timer == nil {
      identifier = self.object.shortID.isEmpty == false ? self.object.shortID : nil
    } else {
      identifier = nil
    }
    return identifier.map{
      _ in
      Text("Waiting For Heart Rate...").onAppear(perform: self.object.beginMonitoring)
    }
  }
  
  var heartRateView : some View {
    self.object.workoutData?.heartRate.map{
      Text("\($0)")
    }
  }
}

struct HeartwitchView_Previews: PreviewProvider {
  static var previews: some View {
    HeartwitchView()
  }
}
