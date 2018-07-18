package ;

import action.LearnerAction;
import model.Learner;
import action.TeacherAction;
import model.Teacher;
import action.ScholaeAction;
import model.Scholae;
import redux.Redux;
import redux.Store;
import redux.StoreBuilder.*;

class ApplicationStore {

    static public function create():Store<ApplicationState> {
        // store model, implementing reducer and middleware logic
        var scholae = new Scholae();
        var teacher = new Teacher();
        var learner = new Learner();

        // create root reducer normally, excepted you must use
        // 'StoreBuilder.mapReducer' to wrap the Enum-based reducer
        var rootReducer = Redux.combineReducers({
            scholae: mapReducer(ScholaeAction, scholae),
            teacher: mapReducer(TeacherAction, teacher),
            learner: mapReducer(LearnerAction, learner)
        });

        // create middleware normally, excepted you must use
        // 'StoreBuilder.mapMiddleware' to wrap the Enum-based middleware
        var middleware = Redux.applyMiddleware(
            mapMiddleware(ScholaeAction, scholae),
            mapMiddleware(TeacherAction, teacher),
            mapMiddleware(LearnerAction, learner)
        );

        // user 'StoreBuilder.createStore' helper to automatically wire
        // the Redux devtools browser extension:
        // https://github.com/zalmoxisus/redux-devtools-extension
        return createStore(rootReducer, null, middleware);
    }
}
