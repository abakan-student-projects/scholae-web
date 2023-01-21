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
package org.amqp.methods.connection;

    import org.amqp.Method;
    import org.amqp.LongString;
    import org.amqp.methods.ArgumentReader;
    import org.amqp.methods.ArgumentWriter;
    import org.amqp.methods.MethodArgumentReader;
    import org.amqp.methods.MethodArgumentWriter;
    import org.amqp.impl.ByteArrayLongString;

    class Secure extends Method implements ArgumentReader implements ArgumentWriter {
         public var challenge : LongString;
         public function new() {
             super();
    	     challenge = new ByteArrayLongString();
             hasResponse = true;

             classId = 10;
             methodId = 20;
         }
         
         public override function getResponse():Method {
             return new SecureOk();
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeLongstr(challenge);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             challenge = reader.readLongstr();
         }

    }
