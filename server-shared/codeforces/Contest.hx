package codeforces;

/**
* https://codeforces.com/api/help/objects#Contest
**/

typedef Contest = {
    id: Int,
    name: String,
    type: String,
    phase: String,
    frozen: String,
    durationSeconds: Int,
    ?startTimeSeconds: Float,
    ?relativeTimeSeconds: Int,
    ?preparedBy: String,
    ?websiteUrl: String,
    ?description: String,
    ?difficulty: Int,
    ?kind: String,
    ?icpcRegion: String,
    ?country: String,
    ?city: String,
    ?season: String
}
