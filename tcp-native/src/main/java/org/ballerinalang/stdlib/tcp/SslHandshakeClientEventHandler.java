/*
 * Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.ballerinalang.stdlib.tcp;

import io.ballerina.runtime.api.Future;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.handler.flow.FlowControlHandler;
import io.netty.handler.ssl.SslHandshakeCompletionEvent;
import org.ballerinalang.stdlib.tcp.nativeclient.Client;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Class to handle SSL handshake event of TCP Client.
 */
public class SslHandshakeClientEventHandler extends ChannelInboundHandlerAdapter {
    private TcpClientHandler tcpClientHandler;
    private Future balClientInitCallback;
    private static final Logger log = LoggerFactory.getLogger(Client.class);

    public SslHandshakeClientEventHandler(TcpClientHandler handler, Future callback) {
        tcpClientHandler = handler;
        this.balClientInitCallback = callback;
    }

    @Override
    public void userEventTriggered(ChannelHandlerContext ctx, Object event) throws Exception {
        if (event instanceof SslHandshakeCompletionEvent) {
            if (((SslHandshakeCompletionEvent) event).isSuccess()) {
                ctx.pipeline().addLast(Constants.FLOW_CONTROL_HANDLER, new FlowControlHandler());
                ctx.pipeline().addLast(Constants.CLIENT_HANDLER, tcpClientHandler);
                balClientInitCallback.complete(null);
                ctx.pipeline().remove(this);
            } else {
                balClientInitCallback.complete(Utils.createSocketError(((SslHandshakeCompletionEvent) event).
                        cause().getMessage()));
                ctx.close();
            }
        }
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        log.error("Error while SSL handshake: " + cause.getMessage());
    }
}
