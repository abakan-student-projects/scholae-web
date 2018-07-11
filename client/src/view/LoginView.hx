package view;

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
                <form>
                    <fieldset className="uk-fieldset">

                        <legend className="uk-legend">Login</legend>

                        <div className="uk-margin">
                            <input name="email" className="uk-input" type="text" placeholder="E-mail" ref="email"/>
                        </div>

                        <div className="uk-margin">
                            <input name="password" className="uk-input" type="password" placeholder="Password" ref="password" />
                        </div>

                    </fieldset>

                </form>
                <button className="uk-button uk-button-default" onClick=$onClick>Войти</button>
                <Link to="/registration">Зарегистрироваться</Link>
             </div>
            ');
    }

    function onClick(_) {
        props.signIn(refs.email.value, refs.password.value);
    }
}
