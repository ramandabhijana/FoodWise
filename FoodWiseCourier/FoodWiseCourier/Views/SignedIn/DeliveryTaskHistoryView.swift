//
//  DeliveryTaskHistoryView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import SwiftUI

struct DeliveryTaskHistoryView: View {
  @StateObject private var viewModel: DeliveryTaskHistoryViewModel
  
  init(viewModel: DeliveryTaskHistoryViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    List {
      ForEach(viewModel.taskHistory, id: \.taskId) { task in
        DeliveryTaskCell(
          viewModel: viewModel,
          deliveryTask: task)
      }
      .padding(.vertical, 4)
      .listRowBackground(Color.clear)
      .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .background(Color.backgroundColor)
    .navigationTitle("Delivery Task History")
    .snackBar(
      isShowing: $viewModel.showingError,
      text: Text("Unknown error occurred"),
      isError: true
    )
    .overlay {
      if viewModel.taskHistory.isEmpty {
        VStack {
          Image("empty_list")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
          Text("No results").font(.subheadline)
        }
        .frame(
          width: UIScreen.main.bounds.width,
          height: UIScreen.main.bounds.height
        )
      }
    }
  }
  
}

private struct DeliveryTaskCell: View {
  @State private var showingDetails = false
  @ObservedObject var viewModel: DeliveryTaskHistoryViewModel
  
  var deliveryTask: DeliveryTask
  
  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack {
        Text(DeliveryTaskHistoryViewModel.cellAssignedDateFormatter.string(from: deliveryTask.requestedDate.dateValue()))
          .font(.subheadline)
        Spacer()
        Text(deliveryTask.serviceWage.asIndonesianCurrencyString())
          .fontWeight(.bold)
      }
      
      RouteDetailsView(pickupAddress: deliveryTask.pickupAddress.geocodedLocation, pickupDetails: deliveryTask.pickupAddress.details, destinationAddress: deliveryTask.dropOffAddress.geocodedLocation, destinationDetails: deliveryTask.dropOffAddress.details)
      
      Group {
        Text("Requester: ") + Text(" \(deliveryTask.requesterName)").bold()
      }
      .font(.footnote)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.white)
        .shadow(radius: 2)
    )
    .redacted(reason: viewModel.loadingTaskHistory ? .placeholder : [])
    .onTapGesture {
      guard !viewModel.loadingTaskHistory else { return }
      showingDetails = true
    }
  }
}

private extension DeliveryTaskCell {
  struct RouteDetailsView: View {
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
            .font(.subheadline)
            .fontWeight(.light)
            .padding(.leading, 30)
          HStack(alignment: .top, spacing: 10) {
            VStack {
              Image(systemName: "circle.circle")
                .font(.subheadline.bold())
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
                .font(.subheadline)
                .bold()
              Text("Details: \(pickupDetails.isEmpty ? "-" : pickupDetails)")
                .font(.footnote)
            }
            .readSize { pickupLocationVLineSize = $0 }
          }
        }
        
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
              .font(.subheadline)
              .fontWeight(.light)
              .readSize { destinationLocationVLineSize = $0 }
          }
          HStack(alignment: .top, spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
              .font(.subheadline.bold())
              .frame(width: 20)
            VStack(alignment: .leading) {
              Text(destinationAddress)
                .font(.subheadline)
                .bold()
              Text("Details: \(destinationDetails.isEmpty ? "-" : destinationDetails)")
                .font(.footnote)
            }
          }
        }
      }
    }
  }
}
