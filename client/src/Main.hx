package;

import services.AuthServiceClient;
import services.Session;
import view.LoginScreen;
import view.LearnerDashboardScreen;
import action.ScholaeAction;
import js.html.Element;
import view.LoginView;
import js.html.DivElement;
import redux.Store;
import router.ReactRouter;
import router.RouteComponentProps;
import js.Browser;
import react.ReactDOM;
import react.ReactMacro.jsx;
import redux.Store;
import redux.react.Provider;
import router.Link;
import router.ReactRouter;
import router.RouteComponentProps;

class Main {

    /**
		Entry point:
		- setup redux store
		- setup react rendering
		- send a few test messages
	**/

    private static var store: Store<ApplicationState>;

    public static function main() {
        store = ApplicationStore.create();
        render(Browser.document.getElementById('app'), store);
    }

    static function render(root: Element, store:Store<ApplicationState>)
    {
        var history = ReactRouter.browserHistory;

        var app = ReactDOM.render(jsx('
            <Provider store=$store>
				<Router history=$history>
					<Route path="/" component=$pageWrapper>
					    <IndexRoute component=$LearnerDashboardScreen onEnter=$requireAuth/>
					    <Route path="login" component=$LoginScreen />
					</Route>
				</Router>
			</Provider>
		'), root);
    }

    static function pageWrapper(props:RouteComponentProps)
    {
        return jsx('
			<div>
				<nav>
					<Link to="/">Scholae</Link> | <Link to="/">About</Link>
				</nav>
				${props.children}
			</div>
		');
    }

    static function requireAuth(nextState: Dynamic, replace: String->Void, completed:Void->Void) {
        if (store.getState().scholae == null || !store.getState().scholae.auth.loggedIn) {
            if (Session.isUserLoggedIn()) {
                AuthServiceClient.instance.checkSession(Session.sessionId)
                    .then(
                        function(sessionMessage) {
                            store.dispatch(Authenticated(sessionMessage.email, Session.sessionId));
                        },
                        function(e) {
                            Session.logout();
                            replace("/login");
                        });
            } else {
                replace("/login");
            }
        }
        completed();
    }

}