package view.teacher;

import action.LearnerAction;
import messages.TagMessage;
import messages.TrainingMessage;
import haxe.ds.StringMap;
import messages.GroupMessage;
import messages.AssignmentMessage;
import messages.LearnerMessage;
import haxe.ds.ArraySort;
import messages.RatingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.Link;

typedef ClassLearnersRatingProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>,
    assignments: Array<AssignmentMessage>,
    trainingsByUsersAndAssignments: StringMap<StringMap<Array<TrainingMessage>>>,
    tags: StringMap<TagMessage>
    //rating: RatingMessage
}

typedef ClassLearnersRatingRefs = {

}

class ClassLearnersRatingView
            extends ReactComponentOfPropsAndRefs<ClassLearnersRatingProps, ClassLearnersRatingRefs>
            implements IConnectedComponent {

    public function new()
    {
        super();
    }

    override function render() {
        var rows = [ for (l in props.learners) createLearnerRow(l, props.assignments)];
        var state: ApplicationState = context.store.getState();
        //var learnersRating = if (props.learners != null) [for (learner in props.learners) getLearnerRating(Std.parseFloat(Std.string(learner.id)))] else [];
        return jsx('
                <div>
                    <div className="uk-margin">
                        <Link to=${"/teacher/group/" + state.teacher.currentGroup.info.id + ""}><span data-uk-icon="chevron-left"></span> ${state.teacher.currentGroup.info.name} </Link>
                    </div>
                    <table className="uk-table uk-table-divider">
                        <tbody>
                            $rows
                        </tbody>
                    </table>
                </div>
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
        return jsx('<tr key=${learner.id}><td><Link to=${"/teacher/user/" + learner.id +""}>${learner.firstName} ${learner.lastName} </Link></td>$trainings</tr>');
    }

    function getLearnerRating(learnerId: Float) {
        dispatch(LearnerAction.LoadRating(learnerId));
    }
}