package view.teacher;

import utils.DateUtils;
import action.TeacherAction;
import redux.react.IConnectedComponent;
import action.ScholaeAction;
import messages.GroupMessage;
import js.Browser;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;
import router.Link;
import messages.AttemptMessage;

typedef TeacherDashboardProps = {
    groups: Array<GroupMessage>,
    showNewGroupView: Bool,
    lastAttempts: Array<AttemptMessage>
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
                jsx('<NewGroupView dispatch=${dispatch} close=$onCloseAddGroupClick/>')
            else
                jsx('<button className="uk-button uk-button-default" onClick=${onAddGroupClick}>Добавить курс</button>');

        var lastAttempts =
            if (props.lastAttempts != null) {
                var a = [for (a in props.lastAttempts)
                    jsx('
                        <div className="uk-margin" key=${a.id}>
                            ${DateUtils.toStringWithTime(a.datetime)}
                            <Link className="uk-margin-small-left" to=${"http://codeforces.com/contest/" + a.task.id + "/submission/" + a.vendorId}>${a.learner.lastName} ${a.learner.firstName} - ${a.task.name}</Link>
                            <span className=${"uk-label uk-margin-small-left " + if(a.solved)"uk-label-success"else"uk-label-danger"}>${if(a.solved) "Решено" else "Ошибка"}</span>
                        </div>')
                ];
                jsx('<div className="attempts">$a</div>');
            } else
                jsx('<div data-uk-spinner=${true}></div>');

        return jsx('
                <div id="teacher">
                    <h2>Последние действия учеников</h2>
                    $lastAttempts

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

    function onCloseAddGroupClick() {
        dispatch(TeacherAction.HideNewGroupView);
    }

}
