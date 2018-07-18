package model;

import services.LearnerServiceClient;
import action.LearnerAction;
import react.ReactUtil.copy;
import redux.IMiddleware;
import redux.IReducer;
import redux.StoreMethods;
import services.TeacherServiceClient;
import utils.RemoteDataHelper;
import utils.UIkit;

class Learner
    implements IReducer<LearnerAction, LearnerState>
    implements IMiddleware<LearnerAction, ApplicationState> {

    public var initState: LearnerState = {
        groups: RemoteDataHelper.createEmpty(),
        currentGroup: null,
        signup: { redirectTo: null }
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: LearnerState, action: LearnerAction): LearnerState {
        return switch(action) {
            case SignUpToGroup(key): state;
            case SignUpToGroupFinished(group): copy(state, { currentGroup: group } );
            case SignUpRedirect(to): copy(state, { signup: { redirectTo: to } });
        }
    }

    public function middleware(action: LearnerAction, next:Void -> Dynamic) {
        return switch(action) {

            case SignUpToGroup(key):
                LearnerServiceClient.instance.signUp(key)
                    .then(
                        function(group) { store.dispatch(SignUpToGroupFinished(group)); },
                        function(errorMessage) { UIkit.notification({ message: errorMessage, timeout: 10000, status: "warning" }); });
                next();

            case SignUpToGroupFinished(group):
                UIkit.notification({ message: 'Вы выступили в группу "${group.name}" ', timeout: 10000, status: "success" });
                store.dispatch(SignUpRedirect('/learner/group/${group.id}'));
                next();

            default: next();
        }
    }
}
