package view;

import js.Browser;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;

typedef RegistrationViewProps = {
    register: String -> String -> String -> String -> String -> Void,
    //TODO: implement checkCodeforcesId: String -> Void,
    cancel: Void -> Void
}

typedef RegistrationViewRefs = {
    email: InputElement,
    password: InputElement,
    password2: InputElement,
    codeforcesId: InputElement,
    firstName: InputElement,
    lastName: InputElement,
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
                    <fieldset className="uk-fieldset">
                        <legend className="uk-legend">Регистрация</legend>

                        <div className="uk-margin">
                            <input className="uk-form-width-large uk-input" type="text" placeholder="Электронная почта" ref="email"/>
                        </div>
                        <div className="uk-margin">
                            <input className="uk-form-width-large uk-input" type="text" placeholder="Пароль" ref="password"/>
                        </div>
                        <div className="uk-margin">
                            <input className="uk-form-width-large uk-input" type="text" placeholder="Повторите пароль" ref="password2"/>
                        </div>
                        <div className="uk-margin">
                            <input className="uk-form-width-large uk-input" type="text" placeholder="Codeforces логин" ref="codeforcesId"/>
                        </div>
                        <div className="uk-margin">
                            <input className="uk-form-width-large uk-input" type="text" placeholder="Имя" ref="firstName"/>
                        </div>
                        <div className="uk-margin">
                            <input className="uk-form-width-large uk-input" type="text" placeholder="Фамилия" ref="lastName"/>
                        </div>
                        <div className="uk-margin ">
                            <button className="uk-form-width-large uk-button uk-button-primary" onClick=$onRegisterClick>Зарегистрироваться</button>
                        </div>
                        <div className="uk-margin ">
                            <button className="uk-form-width-large uk-button uk-button-default" onClick=$onCancelClick>Отмена</button>
                        </div>
                    </fieldset>
                </div>
            ');
    }

    function onRegisterClick(e) {
        props.register(refs.email.value, refs.password.value, refs.codeforcesId.value, refs.firstName.value, refs.lastName.value);
    }

    function onCancelClick(e) {
        props.cancel();
    }
}
