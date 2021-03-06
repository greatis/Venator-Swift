//
//  network_connections.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

func runNetworkConnections(system_info: SystemInfo) {
    // get network connections
    print("[+] Gathering network connection data")
    let network_connections = getNetworkConections(system_info: system_info)
    if network_connections.count > 0 {
        config.venator_data.network_connections = network_connections
    }
}

func getNetworkConections(system_info: SystemInfo) -> Array<NetworkConnection> {
    var network_connections = Array<NetworkConnection>()
    // Set the task parameters
    let task = Process()
    task.launchPath = "/usr/sbin/lsof"
    task.arguments = ["-i", "-w"]

    // Create a Pipe and make the task
    // put all the output there
    let pipe = Pipe()
    task.standardOutput = pipe
    // Launch the task
    task.launch()
    task.waitUntilExit()

    // Get the data
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8) ?? ""
    let split = output.split(separator: "\n")
    var conn_list = Array<String>()
    for i in split {
        if String(i).contains("ESTABLISHED") {
            conn_list.append(String(i))
        }
    }
    for i in conn_list {
        let d = i.split(separator: " ")
        let conn = NetworkConnection(hostname: system_info.hostname,
                                     uuid: system_info.uuid,
                                     user: String(d[2]),
                                     process_name: String(d[0]),
                                     process_id: String(d[1]),
                                     TCP_UDP: String(d[7]),
                                     connection_flow: String(d[8]))
        network_connections.append(conn)
    }
    return network_connections
}
