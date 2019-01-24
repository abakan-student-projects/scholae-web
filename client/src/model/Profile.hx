package model;

import utils.RemoteData;
import messages.ProfileMessage;
import utils.RemoteDataHelper;
import action.ProfileAction;
import react.ReactUtil.copy;
import redux.IMiddleware;
import redux.IReducer;
import redux.StoreMethods;
import services.AuthServiceClient;
import utils.UIkit;

typedef ProfileState = {
    data: RemoteData<ProfileMessage>,
}

class Profile
    implements IReducer<ProfileAction, ProfileState>
    implements IMiddleware<ProfileAction, ApplicationState> {

    public var initState: ProfileState = {
        data: RemoteDataHelper.createEmpty()
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: ProfileState, action: ProfileAction): ProfileState {
        trace(action);
        return switch(action) {
            case Clear: initState;
            case GetProfile: copy(state, { data: RemoteDataHelper.createLoading() });
            case UpdateProfile(codeforcesHandle, firstName, lastName): copy(state, {
                data: RemoteDataHelper.createLoading()
            });
            case UpdateProfileFinished(profileMessage): copy(state, {
                data: RemoteDataHelper.createLoaded(profileMessage)
            });
        }
    }

    public function middleware(action: ProfileAction, next:Void -> Dynamic) {
        trace(action);
        return switch(action) {
            case GetProfile:
                AuthServiceClient.instance.getProfile().then(
                    function(profileMessage) {
                        store.dispatch(UpdateProfileFinished(profileMessage));
                    },
                    function(e) {
                        UIkit.notification({
                            message: "Ошибка загрузки профиля: " + e + ".", timeout: 5000, status: "warning"
                        });
                });
                next;

            case UpdateProfile(codeforcesHandle, firstName, lastName):
                AuthServiceClient.instance.updateProfile(codeforcesHandle, firstName, lastName).then(
                    function(profileMessage) {
                        UIkit.notification({ message: "Профиль обновлён", timeout: 5000, status: "success" });
                        store.dispatch(UpdateProfileFinished(profileMessage));
                    },
                    function(e) {
                        UIkit.notification({
                            message: "Ошибка обновления профиля: " + e + ".", timeout: 5000, status: "warning"
                        });
                    });
                next;

            default: next();
        }
    }

}
