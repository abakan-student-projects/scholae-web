package view.teacher;

import action.TeacherAction;
import utils.UIkit;
import utils.DateUtils;
import haxe.ds.ArraySort;
import haxe.ds.StringMap;
import messages.AssignmentMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;
import react.ReactComponent;
import redux.react.IConnectedComponent;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import react.ReactUtil.copy;
import utils.DateUtils;
import utils.StringUtils;
import router.Link;
import view.teacher.TeacherTrainingCellView;

typedef TeacherAssignmentsGridProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>,
    assignments: Array<AssignmentMessage>,
    trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>,
    tags: StringMap<TagMessage>
}

typedef TeacherAssignmentsGridState = {
    learnerId: Float,
    groupId: Float
}

class TeacherAssignmentsGridView extends ReactComponentOfProps<TeacherAssignmentsGridProps> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {
        var header = createAssignmentsHeaderRow(props.assignments);
        var rows = [ for (l in props.learners) createLearnerRow(l, props.assignments)];
        var delete = jsx('<div id="deleteForm" data-uk-modal="${true}" key="1">
                                    <div className="uk-modal-dialog uk-margin-auto-vertical">
                                        <div className="uk-modal-body">
                                            Вы действительно хотите удалить этого ученика?
                                        </div>
                                        <div className="uk-modal-footer uk-text-right">
                                            <button className="uk-button uk-button-default uk-margin-left uk-modal-close" onClick=$cancelDelete>Отмена</button>
                                            <button className="uk-button uk-button-danger uk-margin-left uk-modal-close" type="button" onClick=$deleteLearner>Удалить</button>
                                        </div>
                                    </div>
                                </div>');
        return jsx('
                <table className="uk-table uk-table-divider">
                    $header
                    <tbody>
                        $rows
                        $delete
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
        return jsx('<tr key=${learner.id}><td><div className="uk-flex">${learner.firstName} ${learner.lastName} <button data-uk-icon="trash" onClick=${startDeleteLearner.bind(learner.id,props.group )}></button></div></td>$trainings</tr>');
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

    function startDeleteLearner(learnerID: Float, groupId: GroupMessage){
        setState(copy(state, {learnerId: learnerID, groupId: groupId.id}));
        UIkit.modal("#deleteForm").show();
    }

    function cancelDelete(){
        setState(copy(state, {learnerId: null, groupId: null}));
    }

    function deleteLearner(){
        dispatch(TeacherAction.DeleteLearnerFromCourse(
                Std.parseFloat(Std.string(state.learnerId)),
                Std.parseFloat(Std.string(state.groupId))
        ));
        cancelDelete();
    }
}
