package view.teacher;

import redux.react.IConnectedComponent;
import action.ScholaeAction;
import messages.GroupMessage;
import js.Browser;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;

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
        var list = [ for (g in props.groups) jsx('<div key=${g.id}>${g.name}</div>') ];
        var newGroup =
            if (props.showNewGroupView)
                jsx('<NewGroupView dispatch=${dispatch}/>')
            else
                jsx('<button onClick=${onAddGroupClick}>Добавить группу</button>');
        return jsx('
                <div id="teacher">
                    <h1>Teacher dashboard</h1>
                    $list
                    $newGroup
                </div>
            ');
    }

    function onAddGroupClick(e) {
        dispatch(ScholaeAction.ShowNewGroupView);
    }

}
