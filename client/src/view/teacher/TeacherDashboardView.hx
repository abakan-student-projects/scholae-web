package view.teacher;

import action.TeacherAction;
import redux.react.IConnectedComponent;
import action.ScholaeAction;
import messages.GroupMessage;
import js.Browser;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;
import router.Link;

typedef TeacherDashboardProps = {
    groups: Array<GroupMessage>,
    showNewGroupView: Bool
}

class TeacherDashboardView extends ReactComponentOfProps<TeacherDashboardProps> implements IConnectedComponent {

    public function new()
    {
        super();
    }

    override function render() {
        var list = [ for (g in props.groups) jsx('<div key=${g.id}><Link to=${"/teacher/group/" + g.id}>${g.name}</Link></div>') ];
        var newGroup =
            if (props.showNewGroupView)
                jsx('<NewGroupView dispatch=${dispatch}/>')
            else
                jsx('<button onClick=${onAddGroupClick}>Добавить группу</button>');
        return jsx('
                <div id="teacher">
                    <h2>Последние 10 действий обучающихся</h2>
                    ...
                    <h2>Группы</h2>
                    $list
                    $newGroup
                </div>
            ');
    }

    function onAddGroupClick(e) {
        dispatch(TeacherAction.ShowNewGroupView);
    }

}
