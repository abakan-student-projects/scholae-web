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


           <div className="uk-height-1-1 uk-flex uk-flex-middle uk-flex-center" id="forget">
            <div>
            		  <p className="uk-text ">Укажите почту, для которого хотите восстановить пароль.</p>
                    <div className="uk-margin">
                        <input className="uk-width-1-1 uk-form-small" type="text" placeholder="Введите электронную почту" ref="email"/>
                    </div>
                    <div className="uk-margin ">
                        <button className="uk-width-1-1 uk-button uk-button-primary uk-button-small " onClick=$onClick>Отправить</button>
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
        props.renewPassword(refs.email.value);

    }

}
