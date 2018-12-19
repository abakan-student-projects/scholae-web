package view.teacher;

import view.teacher.TeacherViewsHelper;
import messages.RatingMessage;
import view.teacher.ClassLearnersRatingView.ClassLearnersRatingProps;
import view.teacher.ClassLearnersRatingView;
import action.TeacherAction;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import utils.RemoteDataHelper;


class ClassLearnersRatingScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, ClassLearnersRatingProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<ClassLearnersRatingView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): ClassLearnersRatingProps {
        RemoteDataHelper.ensureRemoteDataLoaded(state.teacher.allRating, TeacherAction.LoadAllRating(props.params.id));
        TeacherViewsHelper.ensureGroupLoaded(props.params.id, state);

        return {
            group: if (null != state.teacher.currentGroup) state.teacher.currentGroup.info else null,
            learners: if (null != state.teacher.currentGroup && state.teacher.currentGroup.learners.loaded)
                        state.teacher.currentGroup.learners.data
                    else [],

            rating: if (null != state.teacher.allRating) state.teacher.allRating.data else null
        };
    }

}
