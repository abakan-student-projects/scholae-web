package view.teacher;

import js.jquery.JQuery;
import action.TeacherAction;
import utils.UIkit;
import utils.DateUtils;
import haxe.ds.StringMap;
import messages.AssignmentMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.ReactUtil.copy;
import redux.react.IConnectedComponent;
import utils.StringUtils;

typedef TeacherAssignmentsListProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>,
    assignments: Array<AssignmentMessage>,
    trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>,
    tags: StringMap<TagMessage>,
}

typedef TeacherAssignmentsListState = {
    learnerId: Float,
    groupId: Float
}

class TeacherAssignmentsListView extends ReactComponentOfProps<TeacherAssignmentsListProps> implements IConnectedComponent{

    public function new() { super(); }

    override function render() {
        var assingments = [ for (a in props.assignments) renderAssignment(a)];
        return jsx('<ul data-uk-accordion=${true} className="assignments">$assingments</ul>');
    }

    function renderAssignment(a: AssignmentMessage) {
        var rows = [ for (l in props.learners) renderLearnerRow(l, a)];
        var delete = jsx('<div id="deleteForm" className="teacherLearnerDelete" data-uk-modal="${true}" >
                                    <div className="uk-modal-dialog uk-margin-auto-vertical">
                                        <div className="uk-modal-body">
                                            Вы действительно хотите удалить этого ученика?
                                        </div>
                                        <div className="uk-modal-footer uk-text-right">
                                            <button className="uk-button uk-button-default uk-margin-left uk-modal-close" onClick=$cancelDeleteLearner>Отмена</button>
                                            <button className="uk-button uk-button-danger uk-margin-left uk-modal-close" type="button" onClick=$deleteLearnerFromList>Удалить</button>
                                        </div>
                                    </div>
                                </div>');
        return jsx('
                <li key=${a.id} className="assignment">
                    <a className="uk-accordion-title" href="#">
                        ${a.name} <span className="uk-label uk-margin-right">${a.metaTraining.length} ${StringUtils.getTaskStringFor(a.metaTraining.length)}</span>
                        ${DateUtils.toString(a.startDate)} - ${DateUtils.toString(a.finishDate)}
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
                            $delete
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
                    <td>
                        ${learner.firstName} ${learner.lastName}<button data-uk-icon="trash" onClick=${startDeleteLearner.bind(learner.id,props.group )}></button>
                    </td>
                    <TeacherTrainingCellView training=$t tags=${props.tags} group=${props.group} assignment=$a/>
                </tr>');
    }

    function startDeleteLearner(learnerID: Float, groupId: GroupMessage){
        UIkit.modal(".teacherLearnerDelete").show();
        setState(copy(state, {learnerId: learnerID, groupId: groupId.id}));
    }

    override function componentWillUnmount(){
        new js.JQuery(".teacherLearnerDelete").remove();
    }

    function cancelDeleteLearner(){
        setState(copy(state, {learnerId: null, groupId: null}));
    }

    function deleteLearnerFromList(){
        dispatch(TeacherAction.DeleteLearnerFromCourse(
            Std.parseFloat(Std.string(state.learnerId)),
            Std.parseFloat(Std.string(state.groupId))
        ));
        cancelDeleteLearner();
    }
}
