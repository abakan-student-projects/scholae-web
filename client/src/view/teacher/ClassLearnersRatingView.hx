package view.teacher;

import utils.RemoteDataHelper;
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
import Lambda;

typedef ClassLearnersRatingProps = {
    group: GroupMessage,
    learners: Array<LearnerMessage>,
    rating: Array<RatingMessage>
}

class ClassLearnersRatingView
            extends ReactComponentOfProps<ClassLearnersRatingProps>
            implements IConnectedComponent {

    public function new()
    {
        super();
    }

    override function render() {
        var state: ApplicationState = context.store.getState();
        var learner = if (props.rating != null && props.learners != null)
                        [for (r in props.rating)
                            for (l in props.learners)
                                if (l.id == r.learner.id)
                                    jsx('<tr key="${r.learner.id}">
                                            <td><Link to=${"/teacher/user/" + r.learner.id +""}>${r.learner.firstName} ${r.learner.lastName}</Link></td>
                                            <td>${r.rating}</td>
                                        </tr>')]
                    else [jsx('<tr key="1"></tr>')];
        return jsx('
                <div key="listLearners">
                    <div className="uk-margin">
                        <Link to=${"/teacher/group/" + state.teacher.currentGroup.info.id + ""}>
                        <span data-uk-icon="chevron-left"></span> ${state.teacher.currentGroup.info.name} </Link>
                    </div>
                    <table className="uk-table uk-table-divider">
                        <thead>
                            <tr>
                                <th>Ученик</th>
                                <th>Рейтинг</th>
                            </tr>
                        </thead>
                        <tbody>
                            $learner
                        </tbody>
                    </table>
                </div>
                ');
    }

}