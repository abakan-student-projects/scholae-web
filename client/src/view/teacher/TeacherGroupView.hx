package view.teacher;

import messages.LearnerMessage;
import action.ScholaeAction;
import messages.GroupMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import view.teacher.LoadingView;
import router.Link;

typedef TeacherGroupProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>
}

class TeacherGroupView extends ReactComponentOfProps<TeacherGroupProps> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {
        var list = [ for (l in props.learners)
                jsx('<div key=${l.id}>
                        <Link to=${"/teacher/group/" + props.group.id +"/learner/" + l.id}>${l.firstName} ${l.lastName}</Link>
                     </div>') ];
        return
            if (null != props.group)
                jsx('
                    <div id="teacher-group">
                        <h1>${props.group.name}</h1>
                        <div id="signin-key">${props.group.signUpKey}</div>
                        $list
                    </div>
                ');
            else
                jsx('<LoadingView description="Группа"/>');
    }

}
