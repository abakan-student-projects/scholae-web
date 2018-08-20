package view;

import js.Browser;
import js.html.InputElement;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.ReactUtil.copy;
import router.ReactRouter;
import router.Link;

typedef ForgetLoginViewProps = {
    renewPassword: String -> Void
}

typedef ForgetLoginViewRefs = {
    email: InputElement,
}

class ForgetLoginView extends ReactComponentOfPropsAndRefs<ForgetLoginViewProps, ForgetLoginViewRefs> {

    public function new()
    {
        super();
    }

    override function render() {
        return
            jsx('
                <div>
                    <p className="uk-text ">Укажите почту, пожалуйста, для которого хотите восстановить пароль.</p>
                    <div className="uk-margin">
                        <input className="uk-input uk-form-width-large" type="text" placeholder="Введите электронную почту" ref="email"/>
                    </div>
                    <div className="uk-margin">
                        <button className="uk-button uk-button-primary" onClick=$onClick>Отправить</button>
                    </div>
                </div>
            ');
    }

    function onClick(_) {
        props.renewPassword(refs.email.value);
    }

}
