package model;

import messages.TaskMessage;
import services.EditorServiceClient;
import react.ReactUtil;
import action.EditorAction;
import action.TeacherAction;
import haxe.ds.ArraySort;
import messages.TagMessage;
import react.ReactUtil.copy;
import redux.IMiddleware;
import redux.IReducer;
import redux.StoreMethods;
import services.TeacherServiceClient;
import utils.IterableUtils;
import utils.RemoteDataHelper;
import utils.UIkit;

class Editor
    implements IReducer<EditorAction, EditorState>
    implements IMiddleware<EditorAction, ApplicationState> {

    public var initState: EditorState = {
        tags: RemoteDataHelper.createEmpty(),
        tasks: RemoteDataHelper.createEmpty(),
        tasksActiveChunkIndex: 0,
        tasksChunkSize: 100,
        tasksFilter: "",
        showNewTagView: false
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: EditorState, action: EditorAction): EditorState {
        trace(action);
        return switch(action) {
            case Clear: initState;

            case LoadTags: copy(state, { tags: RemoteDataHelper.createLoading() });
            case LoadTagsFinished(tags): copy(state, { tags: RemoteDataHelper.createLoaded(tags) });

            case InsertTag(tag): state;
            case InsertTagFinished(tag): copy(state, { tags: RemoteDataHelper.createLoaded(state.tags.data.concat([tag])) });

            case UpdateTag(tag): state;
            case UpdateTagFinished(tag):
                if (state.tags.loaded) {
                    var filtered = state.tags.data.filter(function(t) { return t.id == tag.id; });
                    if (filtered.length > 0) {
                        ReactUtil.assign(filtered[0], [tag]);
                    }
                }
                state;

            case LoadTasks(filter, offset, limit): copy(state, { tasks: RemoteDataHelper.createLoading(), tasksActiveChunkIndex: 0 });
            case LoadTasksFinished(tasks): copy(state, { tasks: RemoteDataHelper.createLoaded(tasks) });

            case UpdateTaskTags(taskId, tagIds): state;
            case UpdateTaskTagsFinished(task):
                if (state.tasks.loaded) {
                    var filtered = state.tasks.data.data.filter(function(t) { return t.id == task.id; });
                    if (filtered.length > 0) {
                        ReactUtil.assign(filtered[0], [task]);
                    }
                }
                state;

            case SetTasksChunkIndex(index):
                if (state.tasksActiveChunkIndex != index) copy(state, { tasksActiveChunkIndex: index, tasks: RemoteDataHelper.createEmpty() }) else state;

            case SetTasksFilter(filter):
                copy(state, { tasksFilter: filter, tasks: RemoteDataHelper.createEmpty() });

            case ShowNewTagView:
                copy(state, { showNewTagView: true });

            case HideNewTagView:
                copy(state, { showNewTagView: false });
        }
    }

    public function middleware(action: EditorAction, next:Void -> Dynamic) {
        trace(action);
        return switch(action) {
            case LoadTags:
                TeacherServiceClient.instance.getAllTags()
                    .then(function(tags) {
                        ArraySort.sort(tags, function(x: TagMessage, y: TagMessage) { return if (x.name > y.name) 1 else -1; });
                        store.dispatch(LoadTagsFinished(tags));
                    });
                next();

            case UpdateTag(tag):
                EditorServiceClient.instance.updateTag(tag)
                    .then(function(tag) { store.dispatch(UpdateTagFinished(tag)); });
                next();

            case UpdateTagFinished(tag):
                UIkit.notification({ message: "Категория " + tag.name + " обновлена.", timeout: 3000 });
                next();

            case InsertTag(tag):
                EditorServiceClient.instance.insertTag(tag)
                    .then(function(tag) { store.dispatch(InsertTagFinished(tag)); });
                next();

            case InsertTagFinished(tag):
                UIkit.notification({ message: "Категория " + tag.name + " добавлена.", timeout: 3000 });
                next();

            case LoadTasks(filter, offset, limit):
                EditorServiceClient.instance.getTasks(filter, offset, limit)
                    .then(function(tasks) {
                        store.dispatch(LoadTasksFinished(tasks));
                    });
                next();

            case UpdateTaskTags(taskId, tagIds):
                EditorServiceClient.instance.updateTaskTags(taskId, tagIds)
                    .then(function(task) {
                        store.dispatch(UpdateTaskTagsFinished(task));
                    });
                next();

            case UpdateTaskTagsFinished(task):
                UIkit.notification({ message: "Категории для задачи " + task.name + " изменены.", timeout: 3000 });
                next();

            default: next();
        }
    }
}
