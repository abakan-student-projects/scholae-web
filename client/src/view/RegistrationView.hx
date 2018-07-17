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
    name: InputElement,
    lastname: InputElement,
}

class RegistrationView extends ReactComponentOfPropsAndRefs<RegistrationViewProps, RegistrationViewRefs> {

    public function new()
    {
        super();
    }

    override function render() {
        return
            jsx('

            <div className="uk-height-1-1 uk-flex uk-flex-middle uk-flex-center">
            <div>
                    <p className="uk-text ">Вся жизнь это массив и ты не знаешь свой индекс</p>

                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-small" type="text" placeholder="E-mail" ref="email"/>
                    </div>
                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-small" type="text" placeholder="Password" ref="password"/>
                    </div>
                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-small" type="text" placeholder="Password2" ref="password2"/>
                    </div>
                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-small" type="text" placeholder="codeforcesId" ref="codeforcesId"/>
                    </div>
                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-small" type="text" placeholder="Name" ref="name"/>
                    </div>
                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-small" type="text" placeholder="Last-Name" ref="lastname"/>
                    </div>
                    <div className="uk-margin ">
                        <button className="uk-width-1-1 uk-button uk-button-primary uk-button-small " onClick=$onRegisterClick>Регистрация</button>
                    </div>
                     <div className="uk-margin ">
                        <button className="uk-width-1-1 uk-button uk-button-primary uk-button-small " onClick=$onCancelClick>Отмена</button>
                    </div>
            </div>
        </div>
            ');
    }

    function onRegisterClick(e) {
        props.register(refs.email.value, refs.password.value, refs.codeforcesId.value, refs.name.value, refs.lastname.value);
    }

    function onCancelClick(e) {
        props.cancel();
    }
    override function componentDidMount() {
        Browser.document.body.classList.toggle("uk-height-1-1", true);
    }

    override function componentWillUnmount() {
        Browser.document.body.classList.remove("uk-height-1-1");
    }
}
