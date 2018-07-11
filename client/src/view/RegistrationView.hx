package view;

import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;

typedef RegistrationViewProps = {
    register: String -> String -> String -> Void,
    //TODO: implement checkCodeforcesId: String -> Void,
    cancel: Void -> Void
}

typedef RegistrationViewRefs = {
    email: InputElement,
    password: InputElement,
    password2: InputElement,
    codeforcesId: InputElement,
}

class RegistrationView extends ReactComponentOfPropsAndRefs<RegistrationViewProps, RegistrationViewRefs> {

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

                        <legend className="uk-legend">Регистрация</legend>

                        <div className="uk-margin">
                            <input name="email" className="uk-input" type="text" placeholder="E-mail" ref="email"/>
                        </div>

                        <div className="uk-margin">
                            <input name="password" className="uk-input" type="password" placeholder="Password" ref="password" />
                        </div>

                        <div className="uk-margin">
                            <input name="password2" className="uk-input" type="password" placeholder="Repeat password" ref="password2" />
                        </div>

                        <div className="uk-margin">
                            <input name="codeforcesId" className="uk-input" type="text" placeholder="CodeForces ID" ref="codeforcesId" />
                        </div>

                    </fieldset>

                </form>
                <button className="uk-button uk-button-default" onClick=$onRegisterClick>Зарегистрироваться</button>
                <button className="uk-button uk-button-default" onClick=$onCancelClick>Отмена</button>
             </div>
            ');
    }

    function onRegisterClick(e) {
        props.register(refs.email.value, refs.password.value, refs.codeforcesId.value);
    }

    function onCancelClick(e) {
        props.cancel();
    }
}
