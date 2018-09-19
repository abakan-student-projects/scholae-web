package view.learner;

import action.LearnerAction;
import js.html.InputElement;
import action.TeacherAction;
import messages.GroupMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;

typedef SignUpToGroupProps = {
}

typedef SignUpToGroupRefs = {
    signUpKey: InputElement
}

class SignUpToGroupView
            extends ReactComponentOfPropsAndRefs<SignUpToGroupProps, SignUpToGroupRefs>
            implements IConnectedComponent {

    public function new()
    {
        super();
    }

    override function render() {
        return jsx('
                <div id="signup">
                    <legend className="uk-legend">Запись на новый курс</legend>
                    <div className="uk-margin">
                        <input className="uk-input uk-form-width-large" ref="signUpKey" placeholder="Ключ для записи на курс"/>
                    </div>
                    <button className="uk-button uk-button-primary" onClick=$onSignUpClick>Записаться</button>
                </div>
            ');
    }

    function onSignUpClick(e) {
        dispatch(LearnerAction.SignUpToGroup(refs.signUpKey.value));
    }
}
