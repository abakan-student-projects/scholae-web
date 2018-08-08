package view.teacher;

import utils.RemoteDataHelper;
import messages.TrainingMessage;
import view.teacher.TeacherTrainingView.TeacherTrainingProps;
import action.TeacherAction;
import haxe.ds.StringMap;
import messages.TagMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import utils.IterableUtils;
import view.teacher.TeacherViewsHelper;


class TeacherTrainingScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, TeacherTrainingProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<TeacherTrainingView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): TeacherTrainingProps {
        TeacherViewsHelper.ensureGroupLoaded(props.params.groupId, state);
        TeacherViewsHelper.ensureTagsLoaded(state);

        var training: TrainingMessage =
            if (null != state.teacher.currentGroup && state.teacher.currentGroup.trainings != null && state.teacher.currentGroup.trainings.loaded)
                Lambda.find(state.teacher.currentGroup.trainings.data, function(t) { return t.id == props.params.trainingId; })
            else null;

        return {
            group:
                if (null != state.teacher.currentGroup) state.teacher.currentGroup.info else null,
            training: training,
            tags:
                if (state.teacher.tags != null && state.teacher.tags.loaded)
                    IterableUtils.createStringMap(state.teacher.tags.data, function(t) { return Std.string(t.id); })
                else
                    new StringMap<TagMessage>(),
            learner:
                if (null != training && state.teacher.currentGroup.learners != null && state.teacher.currentGroup.learners.loaded)
                    Lambda.find(state.teacher.currentGroup.learners.data, function(l) { return l.id == training.userId; })
                else null
        };
    }

}
