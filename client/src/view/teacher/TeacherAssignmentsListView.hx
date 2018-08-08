package view.teacher;

import haxe.ds.StringMap;
import messages.AssignmentMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import utils.StringUtils;

typedef TeacherAssignmentsListProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>,
    assignments: Array<AssignmentMessage>,
    trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>,
    tags: StringMap<TagMessage>,
}

class TeacherAssignmentsListView extends ReactComponentOfProps<TeacherAssignmentsListProps> {

    public function new() { super(); }

    override function render() {
        var assingments = [ for (a in props.assignments) renderAssignment(a)];
        return jsx('<ul data-uk-accordion=${true} className="assignments">$assingments</ul>');
    }

    function renderAssignment(a: AssignmentMessage) {
        var rows = [ for (l in props.learners) renderLearnerRow(l, a)];
        return jsx('
                <li key=${a.id} className="assignment">
                    <a className="uk-accordion-title" href="#">
                        ${a.name} <span className="uk-label">${a.metaTraining.length} ${StringUtils.getTaskStringFor(a.metaTraining.length)}</span> ${a.finishDate.toString()}
                    </a>
                    <table className="uk-table uk-table-divider uk-accordion-content">
                        <thead>
                            <tr>
                                <th>Ученики</th>
                                <th>Задания</th>
                            </tr>
                        </thead>
                        <tbody>
                            $rows
                        </tbody>
                    </table>
                </li>
            ');
    }

    function renderLearnerRow(learner: LearnerMessage, a: AssignmentMessage) {
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
        return jsx('
                <tr key=${learner.id}>
                    <td>${learner.firstName} ${learner.lastName}</td>
                    <TeacherTrainingCellView training=$t tags=${props.tags} group=${props.group} assignment=$a/>
                </tr>');
    }
}
