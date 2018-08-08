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
    signIn: String -> String -> Void
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
                <fieldset className="uk-fieldset">
                    <legend className="uk-legend">Укажите почту, для которой необходимо восстановить пароль.</legend>
                    <div className="uk-margin">
                        <input className="uk-form-width-large uk-input" type="text" placeholder="Электронная почта" ref="email"/>
                    </div>
                    <div className="uk-margin ">
                        <button className="uk-form-width-large uk-button uk-button-primary">Восстановить пароль</button>
                    </div>
                </fieldset>
            ');
    }
}
