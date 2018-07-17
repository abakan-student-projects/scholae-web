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
                    <input ref="name" placeholder="Название"/>
                    <input ref="signUpKey" placeholder="Код для учеников"/>
                    <button onClick=${onClick}>Создать</button>
                </div>
            ');
    }

    function onClick(e) {
        dispatch(TeacherAction.AddGroup(refs.name.value, refs.signUpKey.value));
    }

}
