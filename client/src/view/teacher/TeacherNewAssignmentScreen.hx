package view.teacher;

import router.RouterLocation.RouterAction;
import action.TeacherAction;
import view.teacher.TeacherNewAssignmentView.TeacherNewAssignmentProps;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;


using utils.RemoteDataHelper;

class TeacherNewAssignmentScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, TeacherNewAssignmentProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<TeacherNewAssignmentView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): TeacherNewAssignmentProps {
        if (state.teacher.assignmentCreating) {
            props.router.replace(
                {
                    state: null,
                    search: null,
                    pathname: "/teacher/group/" + state.teacher.currentGroup.info.id,
                    action: RouterAction.POP
                }
            );
        }

        TeacherViewsHelper.ensureGroupLoaded(props.params.id, state);
        TeacherViewsHelper.ensureTagsLoaded(state);

        return {
            tags: state.teacher.tags.dataOrEmptyArray(),
            learners: if (null != state.teacher.currentGroup) state.teacher.currentGroup.learners.data else [],
            possibleTasks: state.teacher.newAssignment.possibleTasks.data,
            cancel: function() {
                props.router.replace(
                    {
                        state: null,
                        search: null,
                        pathname: "/teacher/group/" + state.teacher.currentGroup.info.id,
                        action: RouterAction.POP
                    }
                );
            },
            create: function(learnerIds,name, minLevel, maxLevel, tasksCount, tagIds, taskIds, startDate, finishDate) {
                dispatch(TeacherAction.CreateAssignment(state.teacher.currentGroup.info,
                    {
                        id: null,
                        startDate: startDate,
                        finishDate: finishDate,
                        name: name,
                        learnerIds: learnerIds,
                        metaTraining:
                            {
                                id: null,
                                minLevel: minLevel,
                                maxLevel: maxLevel,
                                tagIds: tagIds,
                                taskIds: taskIds,
                                length: tasksCount
                            },
                        groupId: null
                    }
                ));
            },
            createAdaptive: function(name, startDate, finishDate, tasksCount, learnerIds) {
                dispatch(TeacherAction.CreateAdaptiveAssignment(state.teacher.currentGroup.info,
                    name, startDate, finishDate, tasksCount, learnerIds));
            }
        };
    }
}
