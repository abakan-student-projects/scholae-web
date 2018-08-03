package view.teacher;

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

typedef TeacherGroupProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>,
    assignments: Array<AssignmentMessage>,
    trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>,
    tags: StringMap<TagMessage>,
    trainingsCreating: Bool,
    createTrainings: Void -> Void
}

class TeacherGroupView extends ReactComponentOfProps<TeacherGroupProps> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {

        ArraySort.sort(
            props.assignments,
            function(x: AssignmentMessage, y: AssignmentMessage) { return if (x.finishDate.getTime() > y.finishDate.getTime()) 1 else -1; });

        var header = createAssignmentsHeaderRow(props.assignments);
        var rows = [ for (l in props.learners) createLearnerRow(l, props.assignments)];

        var createTrainingsButton =
                if (props.trainingsCreating) jsx('<button className="uk-button uk-button-default" disabled="true">Создать тренировки</button>')
                else jsx('<button className="uk-button uk-button-default" onClick=${props.createTrainings}>Создать тренировки</button>');

        return
            if (null != props.group)
                jsx('
                    <div id="teacher-group">
                        <h1>${props.group.name}</h1>
                        <div id="signin-key">${props.group.signUpKey}</div>
                        <Link className="uk-button uk-button-default" to=${"/teacher/group/" + props.group.id +"/new-assignment"}>Создать новый блок заданий</Link>
                        $createTrainingsButton
                        <table className="uk-table uk-table-divider">
                            $header
                            <tbody>
                                $rows
                            </tbody>
                        </table>
                    </div>
                ');
            else
                jsx('<LoadingView description="Группа"/>');
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
                var tagIds: StringMap<Bool> = new StringMap<Bool>();
                for (e in t.exercises) {
                    for (tagId in e.task.tagIds) {
                        tagIds.set(Std.string(tagId), true);
                    }
                }
                var tags = [for (tag in tagIds.keys()) jsx('<span key=$tag className="uk-badge">${props.tags.get(tag).name}</span>')];
                trainings.push(jsx('
                        <td key=${a.id}>
                            ${t.exercises.length} задач<br/>
                            $minLevel - $maxLevel уровень<br/>
                            $tags
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
                jsx('<th key=${a.id}><p>${a.name}</p><p>${a.finishDate.toString()}</p></th>')];
        return jsx('
                <thead>
                    <tr>
                        <th>Обучающиеся</th>
                        $columns
                    </tr>
                </thead>
            ');
    }
}
