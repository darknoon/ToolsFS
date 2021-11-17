//
//  ContentView.swift
//  ToolsFS
//
//  Created by Andrew Pouliot on 11/17/21.
//

import SwiftUI

let manager = Manager()

struct ContentView: View {
    @State var n: Int = 0
    
    @State var busy: Bool = false
    
    @State var error: Error? = nil
    
    func operate(_ operation:  @escaping () async throws -> Void) {
        busy = true
        error = nil
        Task{
            do {
                try await operation()
            } catch {
                self.error = error
            }
            busy = false
        }
    }
    
    var body: some View {
        VStack{
            if let error = error {
                Text("Error: \(error.localizedDescription)")
            } else {
                Text("No error")
            }
            Button("Add to Finder") {
                operate(manager.addDomain)
            }.disabled(busy)
            Button("Remove from Finder"){
                operate(manager.removeDomain)
            }
            .disabled(busy)
            Button("Signal change") {
                operate(manager.signalChange)
            }
            .disabled(busy)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
