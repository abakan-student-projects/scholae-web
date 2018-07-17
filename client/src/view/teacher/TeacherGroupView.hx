package view.teacher;

import action.ScholaeAction;
import messages.GroupMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import view.teacher.LoadingView;

typedef TeacherGroupProps = {
    group: GroupMessage
}

class TeacherGroupView extends ReactComponentOfProps<TeacherGroupProps> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {
        return
            if (null != props.group)
                jsx('
                    <div id="teacher-group">
                        <h1>${props.group.name}</h1>
                        <div id="signin-key">${props.group.signUpKey}</div>
                    </div>
                ');
            else
                jsx('<LoadingView description="Группа"/>');
    }

}
