package codeforces;

typedef Submission = {
    id: Int,
    ?contestId: Int,
    creationTimeSeconds: Float,
    relativeTimeSeconds: Float,
    problem: Problem,
    author: Party,
    programmingLanguage: String,
    ?verdict: String,
    testset: String,
    passedTestCount: Int,
    timeConsumedMillis: Int,
    memoryConsumedBytes: Int
}
