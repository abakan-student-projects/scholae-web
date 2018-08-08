package view.teacher;

import action.TeacherAction;
import redux.react.IConnectedComponent;
import action.ScholaeAction;
import js.html.InputElement;
import messages.GroupMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;

typedef NewGroupRefs = {
    name: InputElement,
    signUpKey: InputElement
}

class NewGroupView extends ReactComponentOfRefs<NewGroupRefs> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {
        return jsx('
                <div id="new-group">
                    <input className="uk-input uk-form-width-large uk-margin-right" ref="name" placeholder="Название курса, семестр, год"/>
                    <input className="uk-input uk-form-width-large uk-margin-right" ref="signUpKey" placeholder="Код записи для учеников"/>
                    <button className="uk-button uk-button-primary" onClick=${onClick}>Создать</button>
                </div>
            ');
    }

    function onClick(e) {
        dispatch(TeacherAction.AddGroup(refs.name.value, refs.signUpKey.value));
    }
}
