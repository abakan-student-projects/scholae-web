package jobs;


enum ScholaeJob {
    RefreshResultsForGroup(groupId: Float);
    RefreshResultsForUser(userId: Float);
    UpdateUserResults(userId: Float);
}