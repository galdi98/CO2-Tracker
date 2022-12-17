//
//  HomeView.swift
//  CO2 Tracker
//
//  Created by Francesco Galdiolo on 15/12/22.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack() {
            VStack{
                HStack{
                    Text("Hello User")
                        .font(.headline)
                        .fontWeight(.thin)
                        .frame(alignment: .leading)
                        .navigationBarTitle("CO(2) Tracker")
                    /*Image(String(contentsOfFile: "/Users/francescogaldiolo/Desktop/Screenshot 2022-12-08 at 21.13.59.png"))*/
                }
                Spacer()
                NavigationLink("Show Map"){
                    MapView()
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("<Back")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
