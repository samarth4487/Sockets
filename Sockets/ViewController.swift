//
//  ViewController.swift
//  Sockets
//
//  Created by Samarth Paboowal on 20/11/18.
//  Copyright © 2018 Samarth Paboowal. All rights reserved.
//

import UIKit
import Starscream
import ObjectMapper
import Alamofire

class ViewController: UIViewController, WebSocketDelegate {

    var socket: WebSocket?
    var blockData: Block?
    var totalUTQueue: [Block]?
    var utQueue: [Block]?
    
    let upperHalf: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let connectionStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let upperHalfLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lowerHalf: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lowerHalfLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let clearQueueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("Clear UT Queue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        if let socketUrl = URL(string: "wss://ws.blockchain.info/inv") {
            socket = WebSocket(url: socketUrl)
            socket?.delegate = self
            socket?.connect()
            self.connectionStatusLabel.text = "Connecting"
        }
        
    }
    
    func setupViews() {
        
        view.addSubview(upperHalf)
        upperHalf.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        upperHalf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        upperHalf.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        upperHalf.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5).isActive = true
        
        upperHalf.addSubview(connectionStatusLabel)
        connectionStatusLabel.leadingAnchor.constraint(equalTo: upperHalf.leadingAnchor).isActive = true
        connectionStatusLabel.topAnchor.constraint(equalTo: upperHalf.topAnchor).isActive = true
        connectionStatusLabel.trailingAnchor.constraint(equalTo: upperHalf.trailingAnchor).isActive = true
        connectionStatusLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        upperHalf.addSubview(upperHalfLabel)
        upperHalfLabel.leadingAnchor.constraint(equalTo: upperHalf.leadingAnchor, constant: 20).isActive = true
        upperHalfLabel.trailingAnchor.constraint(equalTo: upperHalf.trailingAnchor, constant: -20).isActive = true
        upperHalfLabel.centerXAnchor.constraint(equalTo: upperHalf.centerXAnchor).isActive = true
        upperHalfLabel.heightAnchor.constraint(equalTo: upperHalf.heightAnchor).isActive = true
        
        view.addSubview(lowerHalf)
        lowerHalf.topAnchor.constraint(equalTo: upperHalf.bottomAnchor).isActive = true
        lowerHalf.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        lowerHalf.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        lowerHalf.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5).isActive = true
        
        lowerHalf.addSubview(lowerHalfLabel)
        lowerHalfLabel.leadingAnchor.constraint(equalTo: lowerHalf.leadingAnchor, constant: 20).isActive = true
        lowerHalfLabel.trailingAnchor.constraint(equalTo: lowerHalf.trailingAnchor, constant: -20).isActive = true
        lowerHalfLabel.centerXAnchor.constraint(equalTo: lowerHalf.centerXAnchor).isActive = true
        lowerHalfLabel.heightAnchor.constraint(equalTo: lowerHalf.heightAnchor).isActive = true
        
        lowerHalf.addSubview(clearQueueButton)
        clearQueueButton.addTarget(self, action: #selector(clearQueueTapped), for: .touchUpInside)
        clearQueueButton.leadingAnchor.constraint(equalTo: lowerHalf.leadingAnchor, constant: 30).isActive = true
        clearQueueButton.bottomAnchor.constraint(equalTo: lowerHalf.bottomAnchor).isActive = true
        clearQueueButton.trailingAnchor.constraint(equalTo: lowerHalf.trailingAnchor, constant: -30).isActive = true
        clearQueueButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    @objc func clearQueueTapped() {
        
        if var queue = self.utQueue {
            for element in queue {
                if var totalQueue = totalUTQueue {
                    if totalQueue.contains(element) {
                        if let index = totalQueue.firstIndex(of: element) {
                            totalQueue.remove(at: index)
                        }
                    }
                }
            }
            queue.removeAll()
            self.lowerHalfLabel.text = ""
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        self.connectionStatusLabel.text = "Connected"
        socket.write(string: "{\"op\":\"blocks_sub\"}")
        socket.write(string: "{\"op\":\"unconfirmed_sub\"}")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Socket Disconnected")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Socket Data Received")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Socket Message Received")
        self.blockData = Mapper<Block>().map(JSONString: text)
        
        var blockString = ""
        
        if let blockData = self.blockData {
            if let op = blockData.op {
                
                //Block Data
                if op == "block" {
                    
                    if let x = blockData.x {
                        if let hash = x.bHash {
                            blockString.append("Hash: \(hash)\n")
                        }
                        if let height = x.height {
                            blockString.append("Height: \(height)\n")
                        }
                        if let btcSent = x.totalBTCSent {
                            blockString.append("BTC Sent: \(btcSent)\n")
                        }
                        if let reward = x.reward {
                            blockString.append("Reward:\(reward)\n")
                        }
                        self.upperHalfLabel.text = blockString
                    }
                    
                } else {  // UT data
                    
                    totalUTQueue = [Block]()
                    totalUTQueue?.append(blockData)
                    
                    fetchBTCPriceFromServer(with: totalUTQueue!.first!)
                }
            }
        }
    }
    
    func displayUTData(with block: Block, and price: Double) {
        
        var shouldBeDisplayed = true
        
        if let x = block.x {
            if let outs = x.outs {
                if outs.count >= 1 {
                    let out = outs.first!
                    if let value = out.value {
                        let price = value/100000000 * price
                        if price > 100 {
                            shouldBeDisplayed = true
                        } else {
                            shouldBeDisplayed = false
                        }
                    }
                }
            }
        }
        if utQueue == nil {
            utQueue = [Block]()
            shouldBeDisplayed == true ? utQueue?.append(block) : print("Less than USD 100")
        } else {
            
            shouldBeDisplayed == true ? utQueue?.append(block) : print("Less than USD 100")
            
            if let count = utQueue?.count {
                if count > 5 {
                    utQueue?.removeFirst()
                }
            }
            
            var blockString = ""
            
            for index in 0 ..< utQueue!.count {
                
                if let x = utQueue![index].x {
                    if let outs = x.outs {
                        if outs.count >= 1 {
                            let out = outs.first!
                            if let value = out.value {
                                let sampleValue = value/100000000
                                let totalPrice = sampleValue * price
                                let formattedPrice = Double(round(totalPrice * 100) / 100)
                                blockString.append("\(index + 1): ")
                                blockString.append("\(formattedPrice) USD, ")
                            }
                        }
                    }
                    
                    if let time = x.time {
                        let date = NSDate(timeIntervalSince1970: time)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                        dateFormatter.timeZone = TimeZone.current
                        let dateString = dateFormatter.string(from: date as Date)
                        blockString.append(dateString)
                    }
                }
                
                blockString.append("\n")
            }
            
            self.lowerHalfLabel.text = blockString
        }
    }
    
    func fetchBTCPriceFromServer(with block: Block) {
        
        Alamofire.request("https://api.coinmarketcap.com/v2/ticker/?limit=1", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (aResponse) in
            
            let response = aResponse.result
            
            switch response {
                
            case .success:
                
                if let responseData = response.value as? [String: Any] {
                    if let data = responseData["data"] as? [String: Any] {
                        if let one = data["1"] as? [String: Any] {
                            if let quotes = one["quotes"] as? [String: Any] {
                                if let USD = quotes["USD"] as? [String: Any] {
                                    if let price = USD["price"] as? Double {
                                        self.displayUTData(with: block, and: price)
                                    }
                                }
                            }
                        }
                    }
                }
                
            case .failure:
                print("failure")
            }
        }
    }

}

