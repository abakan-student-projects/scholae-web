package jobs;

import codeforces_runner.Config;

enum ScholaeJob {
    RefreshResultsForGroup(groupId: Float);
    RefreshResultsForUser(userId: Float);
    UpdateUserResults(userId: Float);
    UpdateCodeforcesData(cfg: Config);
}