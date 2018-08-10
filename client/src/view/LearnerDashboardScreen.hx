package view;

import utils.IterableUtils;
import view.teacher.TeacherViewsHelper;
import action.LearnerAction;
import utils.RemoteDataHelper;
import view.LearnerDashboardView.LearnerDashboardViewProps;
import react.ReactComponent;
import react.ReactMacro.jsx;
import action.ScholaeAction;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import react.ReactComponent.ReactComponentOfPropsAndState;

class LearnerDashboardScreen
extends ReactComponentOfPropsAndState<RouteComponentProps, LearnerDashboardViewProps>
implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }


    override function render() {
        return jsx(' <LearnerDashboardView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): LearnerDashboardViewProps {
        TeacherViewsHelper.ensureTagsLoaded(state);
        RemoteDataHelper.ensureRemoteDataLoaded(state.learner.trainings, LearnerAction.LoadTrainings);

        return {
            trainings: if(state.learner.trainings.loaded) state.learner.trainings.data else null,
            tags:
                if (state.teacher.tags != null && state.teacher.tags.loaded)
                    IterableUtils.createStringMap(state.teacher.tags.data, function(t) { return Std.string(t.id); })
                else null,
            resultsRefreshing: state.learner.resultsRefreshing,
            refreshResults: function() { dispatch(LearnerAction.RefreshResults); }
        }
    }
}
