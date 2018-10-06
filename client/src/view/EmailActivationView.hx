package view;

import js.Browser;
import js.html.InputElement;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.ReactUtil.copy;
import router.ReactRouter;
import router.Link;

typedef EmailActivationViewProps = {
    emailActivation: String -> Void,
    emailActivated: Bool
}

class EmailActivationView extends ReactComponent {

    public function new()
    {
        super();
    }

    override function componentDidMount() {
        var code = props.dispatch.scope.props.params.code;

        return props.emailActivation(code);
    }

    override function render() {
        trace(this);
        var message =
            if (props.emailActivated) "Ваша электронная почта успешно подтверждёна."
            else "Время подтверждения Вашей электронной почты истекло.";
        return
            jsx('
                <div id="activation">
                    <div className="uk-flex uk-flex-middle uk-margin">
                        <h2 className="uk-margin-remove">Подтверждение E-mail</h2>
                    </div>
                    <div className="uk-section uk-padding-small">
                        <div className="uk-container uk-margin-remove uk-padding-remove">$message</div>
                    </div>
                </div>
            ');
    }
}
