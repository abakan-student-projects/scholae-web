package view.teacher;

import js.jquery.JQuery;
import utils.UIkit;
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

typedef TeacherDashboardState = {
    courseId: Float
}
//при удалении курса меняется статус на тру, если deleted == false то все показывается, в остальных связанных таблицах (groups,assignments,trainings,exercises),
// также надо просмотреть те места, где будет проверка на наличие данного курса и заданий, у ученика и учителя
class TeacherDashboardView extends ReactComponentOfProps<TeacherDashboardProps> implements IConnectedComponent {

    public function new()
    {
        super();
    }

    override function render() {
        var list = [ for (g in props.groups) if (g.deleted != true) jsx('<div className="uk-margin" key=${g.id}><span data-uk-icon="users"></span> <Link className="uk-margin-small-left" to=${"/teacher/group/" + g.id}>${g.name}</Link> <button className="uk-margin-left" data-uk-icon="trash" onClick=${startDeleteCourse.bind(g.id)}></button></div>') ];
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
                            <Link className="uk-margin-small-left" to=${"/teacher/group/" + a.groupId + "/training/" + a.trainingId}>${a.learner.lastName} ${a.learner.firstName} - ${a.task.name}</Link>
                            <span className=${"uk-label uk-margin-small-left " + if(a.solved)"uk-label-success"else"uk-label-danger"}>${if(a.solved) "Решено" else "Ошибка"}</span>
                        </div>')
                ];
                jsx('<div className="attempts">$a</div>');
            } else
                jsx('<div data-uk-spinner=${true}></div>');
        var deleteCourse = jsx('<div id="deleteCourseForm" className="deleteTeacherCourse" data-uk-modal="${true}" key="1">
                                    <div className="uk-modal-dialog uk-margin-auto-vertical">
                                        <div className="uk-modal-body">
                                            Вы действительно хотите удалить этот курс?
                                        </div>
                                        <div className="uk-modal-footer uk-text-right">
                                            <button className="uk-button uk-button-default uk-margin-left uk-modal-close" onClick=$cancelDeleteCourse>Отмена</button>
                                            <button className="uk-button uk-button-danger uk-margin-left uk-modal-close" type="button" onClick=$deleteCourse>Удалить</button>
                                        </div>
                                    </div>
                                </div>');

        return jsx('
                <div id="teacher">
                    <h2>Последние действия учеников</h2>
                    $lastAttempts

                    <h2>Курсы</h2>

                    $list
                    $deleteCourse
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

    function startDeleteCourse(courseID: Float){
        setState(copy(state, { courseId: courseID }));
        UIkit.modal("#deleteCourseForm").show();
    }

    function cancelDeleteCourse(){
        setState(copy(state, { courseId: null }));
    }

    function deleteCourse(){
        dispatch(TeacherAction.DeleteCourse(
            Std.parseFloat(Std.string(state.groupId))
        ));
        cancelDeleteCourse();
    }

    override function componentWillUnmount(){
        new JQuery(".teacherCourseDelete").remove();
    }

}
