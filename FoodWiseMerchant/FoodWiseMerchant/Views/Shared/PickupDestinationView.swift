//
//  PickupDestinationView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 04/04/22.
//

import SwiftUI

struct PickupDestinationView: View {
  @State private var pickupLocationVLineSize: CGSize = .init()
  @State private var destinationLocationVLineSize: CGSize = .init()
  let pickupAddress: String
  let pickupDetails: String
  let destinationAddress: String
  let destinationDetails: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      
      VStack(alignment: .leading, spacing: 0) {
        Text("Pickup Location")
          .font(.caption)
          .padding(.leading, 30)
        HStack(alignment: .top, spacing: 10) {
          VStack {
            Image(systemName: "circle.circle")
              .font(.caption.bold())
            VLine()
              .stroke(style: StrokeStyle(
                lineWidth: 1,
                dash: [5])
              )
          }
          .frame(
            width: 20,
            height: pickupLocationVLineSize.height
          )
          VStack(alignment: .leading) {
            Text(pickupAddress)
              .font(.footnote)
              .bold()
            Text("Details: \(pickupDetails.isEmpty ? "-" : pickupDetails)")
              .font(.caption2)
          }
          .readSize { pickupLocationVLineSize = $0 }
        }
      }
      // To fill the space between pickup and destination
      VLine()
        .stroke(style: StrokeStyle(
          lineWidth: 1,
          dash: [5])
        )
        .frame(width: 20, height: 20)
      
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 10) {
          VLine()
            .stroke(style: StrokeStyle(
              lineWidth: 1,
              dash: [5])
            )
            .frame(
              width: 20,
              height: destinationLocationVLineSize.height
            )
          Text("Destination Location")
            .font(.caption)
            .readSize { destinationLocationVLineSize = $0 }
        }
        HStack(alignment: .top, spacing: 10) {
          Image(systemName: "mappin.and.ellipse")
            .font(.caption.bold())
            .frame(width: 20)
          VStack(alignment: .leading) {
            Text(destinationAddress)
              .font(.footnote.bold())
            Text("Details: \(destinationDetails.isEmpty ? "-" : destinationDetails)")
              .font(.caption2)
          }
        }
      }
    }
  }
}
