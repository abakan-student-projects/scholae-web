package jobs;

import model.User;

enum ScholaeJob {
    RefreshResultsForGroup(groupId: Float);
    RefreshResultsForUser(user: User);
}