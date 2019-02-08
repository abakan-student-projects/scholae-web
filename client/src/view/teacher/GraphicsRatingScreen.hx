package view.teacher;

import action.TeacherAction;
import utils.RemoteDataHelper;
import view.teacher.GraphicsRatingView.GraphicsRatingProps;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.RouterLocation.RouterAction;
import js.moment.Moment;

using utils.RemoteDataHelper;

class GraphicsRatingScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, GraphicsRatingProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<GraphicsRatingView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): GraphicsRatingProps {
        TeacherViewsHelper.ensureGroupLoaded(props.params.id, state);
        var startDate = DateTools.delta(Date.now(), -24*60*60*1000*150);
        var endDate = Date.now();
        if (state.teacher.currentGroup != null){
            var learners = Lambda.array(Lambda.map(state.teacher.currentGroup.learners.data, function(l){return l.id;}));
            RemoteDataHelper.ensureRemoteDataLoaded(
                state.teacher.currentGroup.rating, TeacherAction.LoadRatingsForCourse(learners,
                new Date(startDate.getFullYear(),startDate.getMonth(), startDate.getDate(), 0, 0, 0),
                new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate(), 23, 59, 59)));
        }
        return {
                learners: if (state.teacher.currentGroup != null) state.teacher.currentGroup.learners.data else [],
                ratingForLine: if (state.teacher.currentGroup != null) state.teacher.currentGroup.rating.data else []
           }
    }
}
