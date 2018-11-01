package model;

import services.AdminServiceClient;
import action.AdminAction;
import action.EditorAction;
import action.TeacherAction;
import haxe.ds.ArraySort;
import messages.AdminMessage;
import services.EditorServiceClient;
import services.TeacherServiceClient;
import utils.RemoteDataHelper;
import utils.UIkit;
import react.ReactUtil;
import react.ReactUtil.copy;
import redux.IMiddleware;
import redux.IReducer;
import redux.StoreMethods;
import utils.IterableUtils;

class Admin
    implements IReducer<AdminAction, AdminState>
    implements IMiddleware<AdminAction, ApplicationState> {

    public var initState: AdminState = {
        users: RemoteDataHelper.createEmpty(),
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: AdminState, action: AdminAction): AdminState {
        trace(action);
        return switch(action) {
            case Clear: initState;

            case LoadUsers: copy(state, { users: RemoteDataHelper.createLoading() });
            case LoadUsersFinished(users): copy(state, { users: RemoteDataHelper.createLoaded(users) });

        }
    }

    public function middleware(action: AdminAction, next:Void -> Dynamic) {
        trace(action);
        return switch(action) {

            case LoadUsers:
                AdminServiceClient.instance.getAllUsers()
                .then(function(users) {
                    ArraySort.sort(users, function(x: AdminMessage, y: AdminMessage) { return if (x.firstName > y.firstName) 1 else -1; });
                    store.dispatch(LoadUsersFinished(users));
                });
                next();

            default: next();
        }
    }
}
