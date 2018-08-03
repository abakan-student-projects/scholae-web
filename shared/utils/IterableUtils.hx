package utils;

import haxe.ds.StringMap;

class IterableUtils {

    public static function createStringMap<T>(collection: Iterable<T>, getStringKey: T -> String): StringMap<T> {
        var res: StringMap<T> = new StringMap<T>();
        for (c in collection) {
            res.set(getStringKey(c), c);
        }
        return res;
    }

    public static function createStringMapOfArrays<T>(collection: Iterable<T>, getStringKey: T -> String): StringMap<Array<T>> {
        var res: StringMap<Array<T>> = new StringMap<Array<T>>();
        for (c in collection) {
            var key = getStringKey(c);
            var a = res.get(key);
            if (a == null) {
                a = [];
                res.set(key, a);
            }
            a.push(c);
        }
        return res;
    }

    public static function createStringMapOfArrays2<T>(collection: Iterable<T>,
                                                        getStringKey1: T -> String,
                                                        getStringKey2: T -> String): StringMap<StringMap<Array<T>>> {
        var first: StringMap<Array<T>> = createStringMapOfArrays(collection, getStringKey1);
        var second: StringMap<StringMap<Array<T>>> = new StringMap<StringMap<Array<T>>>();
        for (f in first.keys()) {
            second.set(f, createStringMapOfArrays(first.get(f), getStringKey2));
        }
        return second;
    }
}
