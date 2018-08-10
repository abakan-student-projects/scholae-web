package view.teacher;

import utils.DateUtils;
import haxe.ds.ArraySort;
import haxe.ds.StringMap;
import messages.AssignmentMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import utils.StringUtils;
import router.Link;
import view.teacher.TeacherTrainingCellView;

typedef TeacherAssignmentsGridProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>,
    assignments: Array<AssignmentMessage>,
    trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>,
    tags: StringMap<TagMessage>,
}

class TeacherAssignmentsGridView extends ReactComponentOfProps<TeacherAssignmentsGridProps> {

    public function new() { super(); }

    override function render() {

        var header = createAssignmentsHeaderRow(props.assignments);
        var rows = [ for (l in props.learners) createLearnerRow(l, props.assignments)];

        return jsx('
                <table className="uk-table uk-table-divider">
                    $header
                    <tbody>
                        $rows
                    </tbody>
                </table>
                ');
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
            trainings.push(jsx('<TeacherTrainingCellView key=${a.id} training=$t tags=${props.tags} group=${props.group} assignment=$a/>'));
        }
        return jsx('<tr key=${learner.id}><td>${learner.firstName} ${learner.lastName}</td>$trainings</tr>');
    }

    function createAssignmentsHeaderRow(assignments: Array<AssignmentMessage>) {
        var columns = [ for (a in props.assignments)
                jsx('<th key=${a.id}><strong>${a.name}</strong>
                <br/>${DateUtils.toString(a.startDate)}
                <br/>${DateUtils.toString(a.finishDate)}
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
}
