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


            <div className="uk-height-1-1 uk-flex uk-flex-middle uk-flex-center" id="login">
                <div>
                    <h1 className="uk-text-center"><big><big>SCHOLAE</big></big></h1>

                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-large" type="text" placeholder="Электронная почта" ref="email"/>
                    </div>
                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-large" type="password" placeholder="Пароль" ref="password"/>
                    </div>
                    <div className="uk-margin">
                        <button className="uk-width-1-1 uk-button uk-button-primary uk-button-large" onClick=$onClick>Войти</button>
                    </div>
                    <div className="uk-margin">
                        <Link className="uk-width-1-1 uk-button uk-button-large" to="/registration">Зарегистрироваться</Link>
                    </div>
                    <div className="uk-margin">
                        <Link className="uk-float-right uk-link uk-link-muted" to="/forget-password">Забыли пароль?</Link>
                    </div>

                </div>
            </div>

            ');
    }

    override function componentDidMount() {
        Browser.document.body.classList.toggle("uk-height-1-1", true);
    }

    override function componentWillUnmount() {
        Browser.document.body.classList.remove("uk-height-1-1");
    }

    function onClick(_) {
        props.signIn(refs.email.value, refs.password.value);
    }
}
