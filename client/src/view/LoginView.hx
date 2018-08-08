package view;

import js.Browser;
import js.html.InputElement;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.ReactUtil.copy;
import router.ReactRouter;
import router.Link;

typedef LoginViewProps = {
    signIn: String -> String -> Void
}

typedef LoginViewRefs = {
    email: InputElement,
    password: InputElement,
}

class LoginView extends ReactComponentOfPropsAndRefs<LoginViewProps, LoginViewRefs> {

    public function new()
    {
        super();
    }

    override function render() {
        return
            jsx('
                <div>
                    <fieldset className="uk-fieldset">
                        <legend className="uk-legend">Вход</legend>

                        <div className="uk-margin">
                            <input className="uk-form-width-large uk-input" type="text" placeholder="Электронная почта" ref="email"/>
                        </div>
                        <div className="uk-margin">
                            <input className="uk-form-width-large uk-input" type="password" placeholder="Пароль" ref="password"/>
                        </div>
                        <div className="uk-margin">
                            <button className="uk-form-width-large uk-button uk-button-primary" onClick=$onClick>Войти</button>
                        </div>
                        <div className="uk-margin">
                            <Link className="uk-form-width-large uk-button uk-button-default" to="/registration">Зарегистрироваться</Link>
                        </div>
                        <div className="uk-margin">
                            <Link className="uk-link uk-link-muted" to="/forget-password">Забыли пароль?</Link>
                        </div>
                    </fieldset>
                </div>
            ');
    }

    function onClick(_) {
        props.signIn(refs.email.value, refs.password.value);
    }
}
