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
        return props.emailActivation(props.dispatch.scope.props.params.code);
    }

    override function render() {
        var message =
            if (props.emailActivated) "Ваша электронная почта успешно подтверждёна."
            else "Возникла ошибка при подтверждении электронной почты. Обратитесь, пожалуйста, к администратору.";

        return
            jsx('
                <div id="activation">
                    <h2 className="uk-margin-remove">Подтверждение E-mail</h2>
                    <div className="uk-margin">$message</div>
                </div>
            ');
    }
}
