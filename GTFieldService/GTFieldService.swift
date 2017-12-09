//
//  GTFieldService.swift
//  GTFieldService
//
//  Created by Chuyen Trung Tran on 10/7/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

private let itcAccountSecret = "3ac723f53d704e0483bc8bf17da8a449"

import Foundation

public enum Result<T> {
    case failure(GTFieldServiceError)
    case success(T)
}

public typealias LoadGTFieldCompletion = (_ gtfields: Result<[GTFieldSet]>) -> Void
public typealias UploadReceiptCompletion = (_ result: Result<(sessionId: String, currentSubscription: PaidSubscription?)>) -> Void

public typealias SessionId = String

public enum GTFieldServiceError: Error {
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case other(Error)
}

public class GTFieldService {
    
    //static let mockGTFieldData = [gtfields1, gtfields2, gtfields3]
    
    public static let shared = GTFieldService()
    let simulatedStartDate: Date
    
    private var sessions = [SessionId: Session]()
    
    init() {
        let persistedDateKey = "GTFieldSimulatedStartDate"
        if let persistedDate = UserDefaults.standard.object(forKey: persistedDateKey) as? Date {
            simulatedStartDate = persistedDate
        } else {
            let date = Date().addingTimeInterval(-30) // 30 second difference to account for server/client drift.
            UserDefaults.standard.set(date, forKey: "GTFieldSimulatedStartDate")
            
            simulatedStartDate = date
        }
    }
    
    /// Trade receipt for session id
    public func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion) {
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": itcAccountSecret
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                completion(.failure(.other(error)))
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                let session = Session(receiptData: data, parsedReceipt: json)
                self.sessions[session.id] = session
                let result = (sessionId: session.id, currentSubscription: session.currentSubscription)
                completion(.success(result))
            }
        }
        
        task.resume()
    }
    
    /// Use sessionId to get gtfields
    public func gtfields(for sessionId: SessionId, completion: LoadGTFieldCompletion?) {
        guard itcAccountSecret == "3ac723f53d704e0483bc8bf17da8a449" else {
            completion?(.failure(.missingAccountSecret))
            return
        }
        
        guard let _ = sessions[sessionId] else {
            // Chưa khởi tạo session
            completion?(.failure(.invalidSession))
            return
        }
        
        let paidSubscriptions = paidSubcriptions(since: simulatedStartDate, for: sessionId)
        guard paidSubscriptions.count > 0 else {
            completion?(.failure(.noActiveSubscription))
            //
            return
        }
        
        // paidSubscriptions là danh sách các gói đã mua, có cả những gói hết hạn
        // Đoạn này có khi không quan trọng
        for (_, subscription) in paidSubscriptions.enumerated() {
            switch subscription.level {
            case .unlimited:
                if subscription.isActive {
                    
                }
                break
            case .yearly:
                if subscription.isActive {
                    
                }
                break
            case .monthly:
                if subscription.isActive {
                    
                }
                break
            }
        }
//
//        var gtfieldSets = [GTFieldSet]()
//        for (index, subscription) in paidSubscriptions.enumerated() {
//            guard let set = gtfieldSet(number: index) else { continue }
//            switch subscription.level {
//            case .unlimited:
//                gtfieldSets.append(set)
//                break
//            case .yearly:
//                gtfieldSets.append(set)
//                //gtfieldSets.append(set.setLimitedToYearlyGTField())
//                break
//            case .monthly:
//                gtfieldSets.append(set)
//                //gtfieldSets.append(set.setLimitedToMonthlyGTField())
//                break
//            }
//        }
//
//        completion?(.success(gtfieldSets))
    }
    
    private func paidSubcriptions(since date: Date, for sessionId: SessionId) -> [PaidSubscription] {
        if let session = sessions[sessionId] {
            let subscriptions = session.paidSubscriptions.filter { $0.purchaseDate >= date }
            return subscriptions.sorted { $0.purchaseDate < $1.purchaseDate }
        } else {
            return []
        }
    }
//
//
//    public func gtfieldSet(number setNumber: Int) -> GTFieldSet? {
//        guard setNumber < GTFieldService.mockGTFieldData.count else {
//            return nil
//        }
//
//        let bundle = Bundle(for: type(of: self))
//        let url = bundle.bundleURL.appendingPathComponent("GTFields", isDirectory: true)
//        guard FileManager.default.fileExists(atPath: url.path) else {
//            return nil
//        }
//
//        let gtfieldNames = GTFieldService.mockGTFieldData[setNumber]
//        let gtfields = gtfieldNames.map { (name, fileName) -> GTField in
//            let imageUrl = url.appendingPathComponent(fileName)
//            let imageData = try! Data(contentsOf: imageUrl)
//            let image = UIImage(data: imageData)!
//            let gtfield = GTField(name: name, image: image)
//            return gtfield
//        }
//
//        return GTFieldSet(name: "Set \(setNumber + 1)", gtfields: gtfields)
//    }
//
}
//
//private let gtfields1 = [
//    "Aaron Douglas":    "AaronDouglas-Stabby.jpg",
//    "Adam Rush":        "AdamRush-NewYork.jpg",
//    "Andy Obusek":      "AndyObusek.jpg"
//]
//
//private let gtfields2 = [
//    "Chris Wagner":     "ChrisWagner-RWPoster.jpg",
//    "David Worsham":    "DavidWorsham-Tree.jpg",
//    "Evan Dekhayser":   "EvanDekhayser-AirPods.jpg",
//    "Greg Heo":         "GregHeo-Sunny.jpg",
//    "Janie Clayton":    "JanieClayton-Peace.jpg",
//    "Jessy and Catie":  "JessyAndCatie-Xmas.jpg",
//    "Joshua and Ray":   "JoshAndRay.jpg"
//]
//
//private let gtfields3 = [
//    "Chris Wagner":     "ChrisWagner-SanDiego.jpg",
//    "Fuad Kamal":       "FuadKamal-Filtered.jpg",
//    "Janie Clayton":    "JanieClayton-Dinos.jpg",
//    "Jessy and Catie":  "JessyAndCatie-Dog.jpg",
//    "Kelvin Lau":       "KelvinLau-Panda.jpg",
//    "Mike Gazdich":     "MikeGazdich-Bunny.jpg",
//    "Richard Turton":   "RichardTurton-Book.jpg"
//]
//
//private let gtfields4 = [
//    "Jessy and Catie":    "JessyAndCatie-DogeOne.jpg",
//    "Kelvin Lau":         "KelvinLau-Eyes.jpg",
//    "Richard Turton":     "RichardTurton-Bourbon.jpg",
//    "Tammy Coron":        "TammyCoron-TreeHat.jpg",
//    "Tim Mitra":          "TimMitra-GregHeo.jpg",
//    "Joshua and Family":  "JoshAndFamily.jpg"
//]
//
//private let gtfields5 = [
//    "Chris Language":   "ChrisLanguage-Driving.jpg",
//    "Chris Wagner":     "ChrisWagner-Tesla.jpg",
//    "Mike Gazdich":     "MikeGazdich-XmasSweater.jpg",
//    "Richard Turton":   "RichardTurton-HelloKitty.jpg",
//    "Tim Mitra":        "TimMitra-Scream.jpg"
//]
//
//private let gtfields6 = [
//    "Chris Wagner":     "ChrisWagner-Doge.jpg",
//    "David Worsham":    "DavidWorsham-Tie.jpg",
//    "Tim Mitra":        "TimMitra-CoolHouses.jpg",
//    "Ray & Vicki":      "RayAndVicki.jpg",
//    "Cesare Rocchi":    "CesareRocchi-Beer.jpg"
//]

