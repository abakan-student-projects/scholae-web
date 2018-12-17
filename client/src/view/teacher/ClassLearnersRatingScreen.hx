package view.teacher;

import view.teacher.ClassLearnersRatingView.ClassLearnersRatingProps;
import view.teacher.ClassLearnersRatingView.ClassLearnersRatingProps;
import view.teacher.ClassLearnersRatingView;
import action.TeacherAction;
import haxe.ds.StringMap;
import messages.TagMessage;
import utils.IterableUtils;
import view.teacher.TeacherGroupView.TeacherGroupProps;
import view.teacher.TeacherViewsHelper;
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
            tags:
            if (state.teacher.tags != null && state.teacher.tags.loaded)
                IterableUtils.createStringMap(state.teacher.tags.data, function(t) { return Std.string(t.id); })
            else
                new StringMap<TagMessage>(),
        };
    }

}
