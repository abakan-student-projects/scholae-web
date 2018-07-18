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
                    <h1>Enter sign up key for the group</h1>
                    <input ref="signUpKey" placeholder="Ключ для вытупления в группу"/>
                    <button onClick=$onSignUpClick>Вступить в группу</button>
                </div>
            ');
    }

    function onSignUpClick(e) {
        dispatch(LearnerAction.SignUpToGroup(refs.signUpKey.value));
    }
}
