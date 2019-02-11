package jobs;

import model.Config;

enum ScholaeJob {
    RefreshResultsForGroup(groupId: Float);
    RefreshResultsForUser(userId: Float);
    UpdateUserResults(userId: Float);
    UpdateCodeforcesData(cfg: Config);
}