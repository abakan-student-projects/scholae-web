package view.learner;

import view.teacher.TeacherViewsHelper;
import action.TeacherAction;
import utils.RemoteDataHelper;
import action.LearnerAction;
import view.learner.LearnerRatingView;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.RouterLocation.RouterAction;

using utils.RemoteDataHelper;

class LearnerRatingScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, LearnerRatingProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<LearnerRatingView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): LearnerRatingProps {
        if (state.scholae.auth.loggedIn){
            TeacherViewsHelper.ensureTagsLoaded(state);
            RemoteDataHelper.ensureRemoteDataLoaded(state.learner.rating, LearnerAction.LoadRating(props.params.id));
        }

        trace(state);
        return {
            rating: state.learner.rating.data,
            tag: if (state.teacher.tags != null && state.teacher.tags.loaded) state.teacher.tags.data else []
           }
    }
}
