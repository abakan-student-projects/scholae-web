package view.teacher;

import utils.RemoteDataHelper;
import action.LearnerAction;
import action.EditorAction;
import utils.RemoteDataHelper;
import redux.Redux.Action;
import utils.RemoteData;
import action.TeacherAction;
import utils.TimerHelper.defer;

using utils.RemoteDataHelper;

class TeacherViewsHelper {

    public static function ensureGroupsLoaded(state: ApplicationState, ?next: Void -> Void) {
        RemoteDataHelper.ensureRemoteDataLoaded(state.teacher.groups, TeacherAction.LoadGroups, next);
    }

    public static function ensureTagsLoaded(state: ApplicationState, ?next: Void -> Void) {
        RemoteDataHelper.ensureRemoteDataLoaded(state.teacher.tags, TeacherAction.LoadAllTags, next);
    }

    public static function ensureLinksLoaded(state: ApplicationState, ?next: Void -> Void) {
        RemoteDataHelper.ensureRemoteDataLoaded(state.editor.links, EditorAction.LoadLink, next);
    }

    public static function ensureRatingsLoaded(state:ApplicationState, ?next: Void -> Void) {
        RemoteDataHelper.ensureRemoteDataLoaded(state.learner.rating, LearnerAction.LoadRating(), next);
    }

    public static function ensureGroupLoaded(groupId: Float, state: ApplicationState, ?next: Void -> Void) {
        ensureGroupsLoaded(state, function() {
            if(
                state.teacher.groups.loaded &&
                (state.teacher.currentGroup == null || state.teacher.currentGroup.info.id != groupId)) {

                defer(function() {
                    Main.store.dispatch(TeacherAction.SetCurrentGroup(
                        Lambda.find(
                            state.teacher.groups.data,
                            function(g) { return g.id == groupId; })));
                });
            } else {
                if (null != next) next();
            }
        });
    }

    public static function ensureRatingLoaded(state: ApplicationState, learnerId, ?next: Void -> Void) {
        ensureRatingsLoaded(state, function() {
            if (state.learner.rating.loaded && state.learner.rating.data.learner.id != learnerId) {
            defer(function() {
                Main.store.dispatch(LearnerAction.LoadRating(learnerId));
            });
            } else {
                if (null != next) next();
            }
        });

    }
}
