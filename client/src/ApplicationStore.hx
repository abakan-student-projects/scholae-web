package ;

import action.ScholaeAction;
import model.Scholae;
import redux.Redux;
import redux.Store;
import redux.StoreBuilder.*;

class ApplicationStore {

    static public function create():Store<ApplicationState> {
        // store model, implementing reducer and middleware logic
        var scholae = new Scholae();

        // create root reducer normally, excepted you must use
        // 'StoreBuilder.mapReducer' to wrap the Enum-based reducer
        var rootReducer = Redux.combineReducers({
            scholae: mapReducer(ScholaeAction, scholae)
        });

        // create middleware normally, excepted you must use
        // 'StoreBuilder.mapMiddleware' to wrap the Enum-based middleware
        var middleware = Redux.applyMiddleware(
            mapMiddleware(ScholaeAction, scholae)
        );

        // user 'StoreBuilder.createStore' helper to automatically wire
        // the Redux devtools browser extension:
        // https://github.com/zalmoxisus/redux-devtools-extension
        return createStore(rootReducer, null, middleware);
    }
}
