package view.editor;

import haxe.ds.StringMap;
import messages.TagMessage;
import utils.IterableUtils;
import view.editor.EditorTasksView;
import action.EditorAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import utils.RemoteDataHelper;

using utils.RemoteDataHelper;

class EditorTasksScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, EditorTasksProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<EditorTasksView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): EditorTasksProps {
        RemoteDataHelper.ensureRemoteDataLoaded(state.editor.tags, EditorAction.LoadTags);
        RemoteDataHelper.ensureRemoteDataLoaded(
            state.editor.tasks,
            EditorAction.LoadTasks(
                state.editor.tasksFilter,
                state.editor.tasksActiveChunkIndex * state.editor.tasksChunkSize,
                state.editor.tasksChunkSize));
        return {
            tags:
                if (state.editor.tags != null && state.editor.tags.loaded)
                    IterableUtils.createStringMap(state.editor.tags.data, function(t) { return Std.string(t.id); })
                else
                    new StringMap<TagMessage>(),
            tasks: state.editor.tasks.data,
            filter: state.editor.tasksFilter,
            updateTags: function(taskId, tagIds) { dispatch(EditorAction.UpdateTaskTags(taskId, tagIds)); },
            chunkIndex: state.editor.tasksActiveChunkIndex,
            chunkSize: state.editor.tasksChunkSize,

        }
    }
}
