/**
 * ---------------------------------------------------------------------------
 *   Copyright (C) 2008 0x6e6562
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 * ---------------------------------------------------------------------------
 **/
package org.amqp.impl;

    #if flash9
    import flash.utils.ByteArray;
    #else
    import haxe.io.BytesOutput;
    #end

    import org.amqp.BaseCommandReceiver;
    import org.amqp.Command;
    import org.amqp.ConnectionParameters;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.ProtocolEvent;
    import org.amqp.methods.connection.Close;
    import org.amqp.methods.connection.CloseOk;
    import org.amqp.methods.connection.Open;
    import org.amqp.methods.connection.OpenOk;
    import org.amqp.methods.connection.Start;
    import org.amqp.methods.connection.StartOk;
    import org.amqp.methods.connection.Tune;
    import org.amqp.methods.connection.TuneOk;
    import org.amqp.util.BinaryGenerator;
    import org.amqp.util.LongStringHelper;

    /**
     * This is a very simple state machine that performs the connection
     * initialization part of the protocol.
     *
     * These are it's interactions with the server:
     *
     * 1. Receive connection.Start
     * 2. Send connection.StartOk
     * 3. Receive connection.Tune
     * 4. Send connection.TuneOk
     * 5. Send connection.Open
     * 6. Receive connection.OpenOk
     **/
    class ConnectionStateHandler extends BaseCommandReceiver {
        inline static var STATE_CLOSED:Int = 0;
        inline static var STATE_OPEN:Int = 1;
        inline static var STATE_CLOSE_REQUESTED:Int = 2;

        var connectionParams:ConnectionParameters;
        var state:Int;

        public function new(params:ConnectionParameters){
            super();
            connectionParams = params;
            addEventListener(new Start(), onStart);
            addEventListener(new Tune(), onTune);
            //trace("new");
        }

        public override function forceClose():Void {
            //trace("forceClose called");
        }

        public override function closeGracefully():Void {
            if (state == STATE_OPEN) {
                close();
            }
            else {
                state = STATE_CLOSE_REQUESTED;
            }
        }

        public function onCloseOk(event:ProtocolEvent):Void {
            var closeOk:CloseOk = cast( event.command.method, CloseOk);
            state = STATE_CLOSED;
            //trace("got CloseOk");
        }

        ////////////////////////////////////////////////////////////////
        // EVENT HANDLING FOR CONNECTION START
        ////////////////////////////////////////////////////////////////

        public function onStart(event:ProtocolEvent):Void {
            //trace("onStart");
            var start:Start = cast( event.command.method, Start);

            // Doesn't do anything fancy with the properties from Start yet
            var startOk:StartOk = new StartOk();
            var props:haxe.ds.StringMap<Dynamic> = new haxe.ds.StringMap();

            props.set("product", LongStringHelper.asLongString("AS-AMQC"));
            props.set("version", LongStringHelper.asLongString("0.1"));
            props.set("platform", LongStringHelper.asLongString("AS3"));

            startOk.clientproperties = props;
            startOk.mechanism = "AMQPLAIN";

            var credentials:haxe.ds.StringMap<Dynamic> = new haxe.ds.StringMap();
            credentials.set("LOGIN", LongStringHelper.asLongString(connectionParams.username));
            credentials.set("PASSWORD", LongStringHelper.asLongString(connectionParams.password));
            #if flash9
            var buf:ByteArray = new ByteArray();
            #else
            var buf:BytesOutput = new BytesOutput(); buf.bigEndian = true;
            #end
            var generator:BinaryGenerator = new BinaryGenerator(buf);
            generator.writeTable(credentials, false);
            startOk.response = new ByteArrayLongString(buf);
            startOk.locale = "en_US";

            session.sendCommand(new Command(startOk));
        }

        public function onTune(event:ProtocolEvent):Void {
            trace("onTune");
            var tune:Tune = cast( event.command.method, Tune);
            var tuneOk:TuneOk = new TuneOk();
            tuneOk.channelmax = tune.channelmax;
            tuneOk.framemax = tune.framemax;
            tuneOk.heartbeat = tune.heartbeat;
            trace(tune.heartbeat);
            session.sendCommand(new Command(tuneOk));
            var open:Open = new Open();
            open.virtualhost = connectionParams.vhostpath;
            open.capabilities = "";
            open.insist = false;
            session.rpc(new Command(open), onOpenOk);
        }

        public function onOpenOk(event:ProtocolEvent):Void {
            //trace("onOpenOk");
            var openOk:OpenOk = cast( event.command.method, OpenOk);
          
            // Maybe do something with the knownhosts?
            //openOk.knownhosts;
            if (state == STATE_CLOSE_REQUESTED) {
                close();
            }
            else {
                state = STATE_OPEN;
                //dispatchAfterOpenEvent();
            }

            // Call the lifecycle event handlers
            session.emitLifecycleEvent();
        }

        function close():Void {
            var close:Close = new Close();
            close.replycode = 200;
            close.replytext = "Goodbye";
            close.classid = 0;
            close.methodid = 0;
            session.rpc(new Command(close), onCloseOk);
            //trace("sent close");
        }

    }
