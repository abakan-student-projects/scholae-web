package model;

import haxe.ds.ArraySort;
import messages.TrainingMessage;
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
        trainings: RemoteDataHelper.createEmpty(),
        signup: { redirectTo: null },
        resultsRefreshing: false
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: LearnerState, action: LearnerAction): LearnerState {
        return switch(action) {
            case Clear: initState;
            case SignUpToGroup(key): state;
            case SignUpToGroupFinished(group): state;
            case SignUpRedirect(to): copy(state, { signup: { redirectTo: to } });
            case LoadTrainings: copy(state, { trainings: RemoteDataHelper.createLoading() });
            case LoadTrainingsFinished(trainings): copy(state, { trainings: RemoteDataHelper.createLoaded(trainings) });
            case RefreshResults: copy(state, { resultsRefreshing: true });
            case RefreshResultsFinished(trainings):
                copy(state,
                    {
                        resultsRefreshing: false,
                        trainings: RemoteDataHelper.createLoaded(trainings),
                    });
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
                UIkit.notification({ message: 'Вы записались на курс "${group.name}" ', timeout: 10000, status: "success" });
                store.dispatch(SignUpRedirect('/learner'));
                next();

            case LoadTrainings:
                LearnerServiceClient.instance.getMyTrainings()
                    .then(function(trainings) {
                        ArraySort.sort(
                            trainings,
                            function(x: TrainingMessage, y: TrainingMessage) {
                                return if (x.assignment.finishDate.getTime() > y.assignment.finishDate.getTime()) 1 else -1;
                            });
                        store.dispatch(LoadTrainingsFinished(trainings));
                    });
                next();

            case RefreshResults:
                LearnerServiceClient.instance.refreshResults()
                    .then(function(trainings) {
                        ArraySort.sort(
                            trainings,
                            function(x: TrainingMessage, y: TrainingMessage) {
                                return if (x.assignment.finishDate.getTime() > y.assignment.finishDate.getTime()) 1 else -1;
                            });
                        store.dispatch(RefreshResultsFinished(trainings));
                    });
                next();

            case RefreshResultsFinished(trainings):
                UIkit.notification({ message: "Результаты обновлены.", timeout: 3000 });
                next();

            default: next();
        }
    }
}
