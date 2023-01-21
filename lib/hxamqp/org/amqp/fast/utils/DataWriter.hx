package org.amqp.fast.utils;

import haxe.Serializer;

#if flash9
import flash.utils.ByteArray;
class DataWriter {
    var b:ByteArray;

    public function new(){
        b = new ByteArray();
    }

    public function getBytes():ByteArray {
        return b;
    }

    public function bytes(by:ByteArray):Void {
        b.writeBytes(by, by.position, by.length - by.position);
    }

    inline public function string(s:String):Void {
        long(s.length);
        b.writeUTFBytes(s);
    }

    inline public function object(o:Dynamic, compress:Bool = false):Int {
        // for small objects or few fields the compressed version can be bigger
        if(compress) {
            var s = Serializer.run(o);
            var by = new ByteArray();
            by.writeUTFBytes(s);
            by.compress();
            by.position = 0;
            long(by.length);
            bytes(by);
            long(s.length);
            return by.length;
        } else {
            var s = Serializer.run(o);
            string(s);
            return s.length;
        }
    }

    inline public function byte(i:Int) {
        b.writeByte(i);
    }

    inline public function short(i:Int):Void {
        b.writeShort(i);
    }

    inline public function long(i:Int):Void {
        b.writeInt(i);
    }

    inline public function float(f:Float):Void {
        b.writeFloat(f);
    }

    inline public function double(f:Float):Void {
        b.writeDouble(f);
    }

    inline public function bool(b:Bool):Void {
        byte((b == true)? 1 : 0);
    }
}
#else
import haxe.io.BytesOutput;
import haxe.io.Bytes;
class DataWriter {
    public var b:BytesOutput;

    public function new(){
        b = new BytesOutput();
        b.bigEndian = true;
    }

    inline public function getBytes():Bytes {
        return b.getBytes();
    }

    public function bytes(by:Bytes) {
        b.write(by);
    }

    inline public function string(s:String):Void {
        long(s.length);
        b.writeString(s);
    }

    inline public function object(o:Dynamic, compress:Bool = false):Int {
        // for small objects or few fields the compressed version can be bigger
        if(compress) {
            var bo = new BytesOutput();
            var s = Serializer.run(o);
            bo.writeString(s);
            var cb = haxe.zip.Compress.run(bo.getBytes(), 9);
            long(cb.length);
            bytes(cb); 
            long(s.length);
            return cb.length;
        } else {
            var s = Serializer.run(o);
            string(s);
            return s.length;
        }
    }

    inline public function byte(i:Int) {
        b.writeByte(i);
    }

    inline public function short(i:Int):Void {
        b.writeInt16(i);
    }

    inline public function long(i:Int):Void {
        b.writeInt32(i);
    }

    inline public function float(f:Float):Void {
        b.writeFloat(f);
    }

    inline public function double(f:Float):Void {
        b.writeDouble(f);
    }

    inline public function bool(b:Bool):Void {
        byte((b == true)? 1 : 0);
    }
}
#end
