package view.teacher;

import messages.RatingMessage;
import utils.StringUtils;
import messages.TagMessage;
import messages.TrainingMessage;
import haxe.ds.StringMap;
import action.TeacherAction;
import haxe.ds.ArraySort;
import messages.AssignmentMessage;
import messages.LearnerMessage;
import action.ScholaeAction;
import messages.GroupMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import view.teacher.LoadingView;
import router.Link;
import view.teacher.TeacherAssignmentsGridView;
import react.ReactUtil.copy;

typedef TeacherGroupProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>,
    assignments: Array<AssignmentMessage>,
    trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>,
    tags: StringMap<TagMessage>,
    trainingsCreating: Bool,
    createTrainings: Void -> Void,
    resultsRefreshing: Bool,
    refreshResults: Void -> Void
}

typedef TeacherGroupState = {
    isGridMode: Bool
}

class TeacherGroupView extends ReactComponentOfPropsAndState<TeacherGroupProps, TeacherGroupState> implements IConnectedComponent {

    public function new() {
        super();
        state = {
            isGridMode: false
        };
    }

    override function render() {

        ArraySort.sort(
            props.assignments,
            function(x: AssignmentMessage, y: AssignmentMessage) { return if (x.finishDate.getTime() > y.finishDate.getTime()) 1 else -1; });

        var createTrainingsButton =
                if (props.trainingsCreating) jsx('<button className="uk-button uk-button-default uk-margin uk-width-1-1" disabled="true">Создать тренировки</button>')
                else jsx('<button className="uk-button uk-button-default uk-margin uk-width-1-1" onClick=${props.createTrainings}>Создать тренировки</button>');

        var refreshResultsButton =
            if (props.resultsRefreshing) jsx('<button className="uk-button uk-button-default uk-margin uk-width-1-1" disabled="true">Обновить результаты</button>')
            else jsx('<button className="uk-button uk-button-default uk-margin uk-width-1-1" onClick=${props.refreshResults}>Обновить результаты</button>');

        var showSpinner =
            if (props.resultsRefreshing) jsx('<span className="uk-margin-left" data-uk-spinner=""></span>')
            else null;

        var assignmentsView =
                if (state.isGridMode) jsx('<TeacherAssignmentsGridView {...props} />')
                else jsx('<TeacherAssignmentsListView {...props} />');

        var gridModeButton = jsx('<button
                        className="uk-icon-button uk-button-default uk-margin-left"
                        type="button" data-uk-icon=${if(state.isGridMode) "table" else "grid"}
                        onClick=$toggleGridMode>
                        </button>');

        return
            if (null != props.group)
                jsx('
                    <div id="teacher-group">
                        <div className="uk-margin">
                            <Link to="/teacher/"><span data-uk-icon="chevron-left"></span>Раздел учителя</Link>
                        </div>
                        <div className="uk-flex uk-flex-middle uk-margin">
                            <h2 className="uk-margin-remove">${props.group.name}</h2>
                            <button className="uk-icon-button uk-button-default uk-margin-left" type="button" data-uk-icon="more"></button>
                            <div data-uk-dropdown="pos: bottom-left">
                                <ul className="uk-nav uk-dropdown-nav">
                                    <li id="signin-key">
                                        <div className="uk-margin uk-width-1-1">Ключ подписки: <strong>${props.group.signUpKey}</strong></div>
                                    </li>
                                    <li>
                                        <Link className="uk-button uk-button-default uk-margin uk-width-1-1 uk-link-reset"
                                            to=${"/teacher/group/" + props.group.id +"/new-assignment"}>
                                            Создать блок заданий
                                        </Link>
                                    </li>
                                    <li>
                                        $createTrainingsButton
                                    </li>
                                    <li>
                                        $refreshResultsButton
                                    </li>
                                </ul>
                            </div>
                            $gridModeButton
                            $showSpinner
                        </div>
                        $assignmentsView
                    </div>
                ');
            else
                jsx('<LoadingView description="Курс"/>');
    }

    function createLearnerRow(learner: LearnerMessage, assignments: Array<AssignmentMessage>) {
        var trainings = [];
        for (a in assignments) {
            var t = null;
            if (props.trainingsByUsersAndAssignments != null) {
                var byUser = props.trainingsByUsersAndAssignments.get(Std.string(learner.id));
                if (byUser != null) {
                    var byAssignment = byUser.get(Std.string(a.id));
                    if (byAssignment != null && byAssignment.length > 0) {
                        t = byAssignment[0];
                    }
                }
            }
            if (t != null && Lambda.count(props.tags) > 0) {
                var minLevel = Lambda.fold(t.exercises, function(e, r) { return Std.int(Math.min(e.task.level, r)); }, 999);
                var maxLevel = Lambda.fold(t.exercises, function(e, r) { return Std.int(Math.max(e.task.level, r)); }, 0);
                var solved = Lambda.count(t.exercises, function(e) { return e.task.isSolved; });
                var tagIds: StringMap<Bool> = new StringMap<Bool>();
                for (e in t.exercises) {
                    for (tagId in e.task.tagIds) {
                        tagIds.set(Std.string(tagId), true);
                    }
                }
                var tags = [for (tag in tagIds.keys()) jsx('<span key=$tag className="uk-margin-small-bottom uk-margin-small-right">${props.tags.get(tag).name} </span> ')];
                var suffix = if (t.exercises.length == 1) "и" else "";
                trainings.push(jsx('
                        <td key=${a.id}>
                            <Link className="uk-link-text" to="${'/teacher/group/' + props.group.id + '/training/' + t.id }">
                                <progress className="uk-progress" value=$solved max=${t.exercises.length}></progress>
                                <div className="uk-margin-small uk-text-meta">Сложность: $minLevel..$maxLevel</div>
                                <div className="uk-text-meta">Категории: $tags</div>
                            </Link>
                        </td>
                    '));
            } else {
                trainings.push(jsx('<td key=${a.id}></td>'));
            }
        }
        return jsx('<tr key=${learner.id}><td>${learner.firstName} ${learner.lastName}</td>$trainings</tr>');
    }

    function createAssignmentsHeaderRow(assignments: Array<AssignmentMessage>) {
        var columns = [ for (a in props.assignments)
                jsx('<th key=${a.id}><strong>${a.name}</strong>
                <br/>${a.finishDate.toString()}
                <br/>${a.metaTraining.length} ${StringUtils.getTaskStringFor(a.metaTraining.length)}</th>')];
        return jsx('
                <thead>
                    <tr>
                        <th>Ученики</th>
                        $columns
                    </tr>
                </thead>
            ');
    }

    function toggleGridMode() {
        setState(copy(state, { isGridMode: !state.isGridMode }));
    }
}
