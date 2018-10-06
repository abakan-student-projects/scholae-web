package view;

import model.Role;
import action.LearnerAction;
import action.TeacherAction;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.Link;

class BaseScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps,Dynamic>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        var state: ApplicationState = context.store.getState();

        var learnerMenuItem =
            if (state.scholae.auth.loggedIn && state.scholae.auth.roles.has(Role.Learner))
                jsx('<li className=${if(props.location.pathname.indexOf("/learner") == 0) "uk-active" else ""}>
                        <Link to="/learner/">Ученик</Link>
                     </li>')
            else
                null;

        var teacherMenuItem =
            if (state.scholae.auth.loggedIn && state.scholae.auth.roles.has(Role.Teacher))
                jsx('<li className=${if(props.location.pathname.indexOf("/teacher") == 0) "uk-active" else ""}>
                        <Link to="/teacher/">Учитель</Link>
                    </li>')
            else
                null;

        var editorMenuItem =
            if (state.scholae.auth.loggedIn && state.scholae.auth.roles.has(Role.Editor))
                jsx('<li className=${if(props.location.pathname.indexOf("/editor") == 0) "uk-active" else ""}>
                        <Link to="/editor/">Редактор</Link>
                        <div className="uk-navbar-dropdown">
                        <ul className="uk-nav uk-navbar-dropdown-nav">
                            <li><Link to="/editor/tags">Категории</Link></li>
                            <li><Link to="/editor/problems">Задачи</Link></li>
                        </ul>
                        </div>
                    </li>')
            else
                null;

        return jsx('
			<div id="scholae">
				<nav className="uk-navbar-container" data-uk-navbar=${true}>
				    <div className="uk-navbar-left uk-margin-left">
				        <Link className="logo-font uk-navbar-item uk-logo" to="/">SCHOLAE<sup>beta</sup></Link>
                        <ul className="uk-navbar-nav">
                            $learnerMenuItem
                            $teacherMenuItem
                            $editorMenuItem
                        </ul>
                     </div>
				    <div className="uk-navbar-right">
				        <div className="uk-navbar-item">
				            ${renderUserInfo()}
				        </div>
				    </div>
				</nav>
				<div className="uk-margin-left uk-margin-right uk-margin">
				    <div id="scholae-content" className="uk-margin-left">
				    ${props.children}
				    </div>
				</div>
				<div className="scholae-footer uk-margin uk-margin-top uk-flex uk-flex-right uk-flex-middle uk-margin-left uk-margin-right">
				    <a data-uk-icon="github" className="uk-icon-button uk-margin-right-small" href="https://github.com/abakan-student-projects/scholae-web/"></a>
				    <a className="uk-link-text" href="https://github.com/abakan-student-projects/scholae-web/issues/EmailActivationScreen">Сообщить об ошибке</a>
				</div>
			</div>
		');
    }

    function onLogoutClick(e) {
        dispatch(ScholaeAction.Clear);
        dispatch(TeacherAction.Clear);
        dispatch(LearnerAction.Clear);
    }

    function renderUserInfo() {
        var state: ApplicationState = context.store.getState();
        return
            if (state.scholae.auth.loggedIn)
                jsx('<div>
                        <span data-uk-icon="user"></span> ${state.scholae.auth.firstName} ${state.scholae.auth.lastName}
                        <Link className="uk-button uk-button-default uk-margin-left" to="/" onClick=$onLogoutClick>Выйти</Link>
                     </div>')
            else
                jsx('<div><Link className="uk-button uk-button-primary uk-margin-left" to="/login">Войти</Link> <Link className="uk-button uk-button-default uk-margin-left" to="/registration">Зарегистрироваться</Link></div>');
    }

    //hack to render when the state is changed
    function mapState(state: ApplicationState, props: RouteComponentProps): Dynamic { return state.scholae.auth; }

}
