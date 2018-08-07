package view.teacher;

import haxe.ds.StringMap;
import messages.TagMessage;
import utils.IterableUtils;
import view.teacher.TeacherViewsHelper;
import model.Teacher;
import action.TeacherAction;
import view.teacher.TeacherGroupView.TeacherGroupProps;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import view.teacher.TeacherDashboardView;


class TeacherGroupScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, TeacherGroupProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<TeacherGroupView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): TeacherGroupProps {
        TeacherViewsHelper.ensureGroupLoaded(props.params.id, state);
        TeacherViewsHelper.ensureTagsLoaded(state);

        return {
            group: if (null != state.teacher.currentGroup) state.teacher.currentGroup.info else null,
            learners:
                if (null != state.teacher.currentGroup && state.teacher.currentGroup.learners.loaded)
                    state.teacher.currentGroup.learners.data
                else [],
            assignments:
                if (null != state.teacher.currentGroup && state.teacher.currentGroup.assignments.loaded)
                    state.teacher.currentGroup.assignments.data
                else [],
            trainingsByUsersAndAssignments:
                if (null != state.teacher.currentGroup)
                    state.teacher.currentGroup.trainingsByUsersAndAssignments
                else null,
            trainingsCreating: state.teacher.trainingsCreating,
            createTrainings: function() {
                if (null != state.teacher.currentGroup) {
                    dispatch(TeacherAction.CreateTrainingsByMetaTrainings(state.teacher.currentGroup.info.id));
                }
            },
            tags:
                if (state.teacher.tags != null && state.teacher.tags.loaded)
                    IterableUtils.createStringMap(state.teacher.tags.data, function(t) { return Std.string(t.id); })
                else
                    new StringMap<TagMessage>(),
            resultsRefreshing: state.teacher.resultsRefreshing,
            refreshResults: function() {
                if (null != state.teacher.currentGroup) {
                    dispatch(TeacherAction.RefreshResults(state.teacher.currentGroup.info.id));
                }
            }
        };
    }

}
