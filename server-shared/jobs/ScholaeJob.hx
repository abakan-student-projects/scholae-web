package jobs;

import codeforces.RunnerConfig;

enum ScholaeJob {
    RefreshResultsForGroup(groupId: Float);
    RefreshResultsForUser(userId: Float);
    UpdateUserResults(userId: Float);
    UpdateCodeforcesData(cfg: RunnerConfig);
}