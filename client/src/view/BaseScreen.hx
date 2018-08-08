package view;

import react.ReactComponent;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.Link;

class BaseScreen
    extends ReactComponent
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        var state = context.store.getState();
        trace(state);
        return jsx('
			<div id="scholae">
				<nav className="uk-navbar-container" data-uk-navbar=${true}>
				    <div className="uk-navbar-left uk-margin-left">
				        <Link className="logo-font uk-navbar-item uk-logo" to="/">SCHOLAE</Link>
                        <ul className="uk-navbar-nav">
                            <li> <Link to="/">О проекте</Link> </li>
                            <li> <Link to="/learner/">Ученик</Link> </li>
                            <li> <Link to="/teacher/">Учитель</Link> </li>
                        </ul>
                     </div>
				</nav>
				<div className="uk-margin-left uk-margin-right uk-margin">
				    <div id="scholae-content" className="uk-margin-left">
				    ${props.children}
				    </div>
				</div>
			</div>
		');
    }
}
