// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java;

# Initializes the TCP connection client based on the 
# provided configurations.
public client class Client {

    # Initializes the TCP client based on the 
    # provided configurations.
    # ```ballerina
    # tcp:Client|tcp:Error? socketClient = new("www.remote.com", 80,
    #                              localHost = "localHost");
    # ```
    # + remoteHost - The hostname or the IP address of the remote host
    # + remotePort - The port number of the remmote host
    # + config - Connection oriented client related configuration
    public isolated function init(string remoteHost, int remotePort, *ClientConfiguration config) returns Error? {
        return externInit(self, remoteHost, remotePort, config);
    }

    # Sends the given data to the connected remote host.
    # ```ballerina
    # tcp:Error? result = socketClient->writeBytes("msg".toBytes());
    # ```
    #
    # + data - The data need to be sent to the connected remote host
    # + return - () or else a `tcp:Error` if the given data can't be sent
    remote function writeBytes(byte[] data) returns Error? {
        return externWriteBytes(self, data);
    }

    // remote function writeBlocksFromStream(stream<byte[]> dataStream) returns Error? { }

    # Reads data only from the connected remote host. 
    # ```ballerina
    # (readonly & byte[])|tcp:Error result = socketClient->readBytes();
    # ```
    #
    # + return - The `readonly & byte[]`, or else a `tcp:Error` if the data
    #            can't be read from the remote host
    remote function readBytes() returns (readonly & byte[])|Error {
        return externReadBytes(self);
    }

    // remote function readBlocksAsStream() returns stream<byte[]>|Error { }

    # Free up the occupied socket.
    # ```ballerina
    # tcp:Error? closeResult = socketClient->close();
    # ```
    #
    # + return - A `tcp:Error` if it can't close the connection or else `()`
    isolated remote function close() returns Error? {
        return externClose(self);
    }
}

# Configurations for the connection oriented tcp client.
# 
# + localHost - Local binding of the interface.
# + timeout - The socket reading timeout value to be used 
#             in seconds. If this is not set,the default value
#             of 300 seconds (5 minutes) will be used.
# + secureSocket - secureSocket configuratoin.
public type ClientConfiguration record {|
    string localHost?;
    decimal timeout = 300;
    ClientSecureSocket secureSocket?;
|};

isolated function externInit(Client clientObj, string remoteHost, int remotePort, ClientConfiguration config) 
returns Error? = @java:Method {
    name: "externInit",
    'class: "org.ballerinalang.stdlib.tcp.nativeclient.Client"
} external;

isolated function externWriteBytes(Client clientObj, byte[] content) returns Error? = @java:Method {
    name: "externWriteBytes",
    'class: "org.ballerinalang.stdlib.tcp.nativeclient.Client"
} external;

isolated function externReadBytes(Client clientObj) returns (readonly & byte[])|Error = @java:Method {
    name: "externReadBytes",
    'class: "org.ballerinalang.stdlib.tcp.nativeclient.Client"
} external;

isolated function externClose(Client clientObj) returns Error? = @java:Method {
    name: "externClose",
    'class: "org.ballerinalang.stdlib.tcp.nativeclient.Client"
} external;
