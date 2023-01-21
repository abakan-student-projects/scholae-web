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
package org.amqp;

    interface Session
    {
        var channel(default, null):Int;
        function closeGracefully():Void;
        function forceClose():Void;
        /**
        * I think sendCommand/2 can be refactored down to sendCommand/1
        * and hence be made more intuitive
        */
        function sendCommand(c:Command, ?fun:Dynamic = null):Void;
        function handleFrame(frame:Frame):Void;
        function rpc(c:Command, fun:Dynamic):Void;
        function registerLifecycleHandler(handler:LifecycleEventHandler):Void;
        function emitLifecycleEvent():Void;

    }
