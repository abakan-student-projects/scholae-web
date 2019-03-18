package codeforces;

/**
* https://codeforces.com/api/help/objects#Problem
**/

typedef Problem = {
    contestId: Int,
    ?problemsetName: String,
    index: String,
    name: String,
    type: String,
    ?points: Float,
    ?rating: Int,
    tags: Array<String>
}
