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
        var list = [ for (g in props.groups) jsx('<div className="uk-margin" key=${g.id}><span data-uk-icon="users"></span> <Link className="uk-margin-small-left" to=${"/teacher/group/" + g.id}>${g.name}</Link></div>') ];
        var newGroup =
            if (props.showNewGroupView)
                jsx('<NewGroupView dispatch=${dispatch}/>')
            else
                jsx('<button className="uk-button uk-button-default" onClick=${onAddGroupClick}>Добавить курс</button>');
        return jsx('
                <div id="teacher">
                    <h2>Последние 10 действий обучающихся</h2>
                    ...

                    <h2>Курсы</h2>

                    $list

                    <div className="uk-margin-top">
                        $newGroup
                    </div>
                </div>
            ');
    }

    function onAddGroupClick(e) {
        dispatch(TeacherAction.ShowNewGroupView);
    }

}
