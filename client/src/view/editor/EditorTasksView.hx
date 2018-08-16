package view.editor;

import haxe.ds.StringMap;
import codeforces.Codeforces;
import action.EditorAction;
import action.EditorAction;
import messages.ArrayChunk;
import messages.TaskMessage;
import js.html.InputElement;
import messages.TagMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.ReactUtil.copy;
import redux.react.IConnectedComponent;
import view.teacher.LoadingView;
import utils.Select;

typedef EditorTasksProps = {
    chunkSize: Int,
    chunkIndex: Int,
    tags: StringMap<TagMessage>,
    tasks: ArrayChunk<TaskMessage>,
    updateTags: Float -> Array<Float> -> Void,
    filter: String
}

typedef EditorTasksRefs = {
    filterInput: InputElement,
    select: Dynamic
}

typedef EditorTasksState = {
    editingTaskId: Float
}

class EditorTasksView extends ReactComponentOfProps<EditorTasksProps> implements IConnectedComponent {

    public function new()
    {
        super();
        state = { filter: "" }
    }

    override function render() {
        return jsx('
                <div id="tasks">
                    <h2>Задачи</h2>
                    <input type="text" className="uk-input uk-form-width-large uk-margin" placeholder="Фильтр" ref="filterInput" value=${props.filter} onChange=$onFilterInputChanged />
                    ${renderTasks()}
                </div>
            ');

    }

    function getTagsForSelect() {
        var tags = Lambda.array(Lambda.map(props.tags, function(t) { return { value: t.id, label: if (null != t.russianName) t.russianName else t.name }; }));
        tags.sort(function(x, y) { return if (x.label < y.label) -1 else 1; });
        return tags;
    }

    function renderTasks() {
        var tags = getTagsForSelect();
        if (props.tasks != null && props.tags != null) {
            var tasks =
            [ for (t in props.tasks.data)
                if (state.editingTaskId != null && state.editingTaskId == t.id)
                    jsx('
                        <tr className="uk-margin" key=${t.id}>
                            <td>
                                <div className="uk-flex uk-flex-middle">
                                    <div>${renderTask(t, false)}</div>
                                    <div className="uk-form-width-large">
                                        <Select
                                            isMulti=${true}
                                            options=${tags}
                                            defaultValue=${getTagsForTask(t, tags)}
                                            placeholder="Выберите категории..."
                                            ref="select"/>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <button className="uk-button uk-button-primary uk-button-small" onClick=$saveEditing>Сохранить</button>
                                <button className="uk-button uk-button-default uk-margin-left uk-button-small" onClick=$cancelEditing>Отмена</button>
                            </td>
                        </tr>
                        ')
                else
                    jsx('
                        <tr className="uk-margin scholae-list-item" key=${t.id}>
                            <td>${renderTask(t)}</td>
                            <td>
                                <div className="scholae-list-item-menu">
                                    <button className="uk-button uk-button-primary uk-button-small" onClick=${startEditing.bind(t.id)}>Изменить</button>
                                </div>
                            </td>
                        </tr>
                    ')
            ];
            return jsx('
                    <div>
                        <table className="uk-table uk-table-divider uk-table-middle uk-table-hover">
                            <thead>
                                <tr>
                                    <th className="uk-table-expand">Название</th>
                                    <th className="uk-width-1-4"></th>
                                </tr>
                            </thead>
                            <tbody>
                                $tasks
                            </tbody>
                        </table>
                        <PaginatorView activePage=${props.chunkIndex+1} pagesCount=${Math.ceil(props.tasks.totalLength/props.chunkSize)} onChange=$onPaginatorChange />
                    </div>
                ');
        } else {
            return jsx('<LoadingView description="Список задач"/>');
        }
    }

    function getTagsForTask(t: TaskMessage, tags: Array<Dynamic>) {
        var result = [];
        for (tag in tags) {
            for (tid in t.tagIds) {
                if (tid == tag.value) result.push(tag);
            }
        }
        return result;
    }

    function renderTask(task: TaskMessage, showTags: Bool = true) {

        var tags = [];
        if (showTags)
            for (tag in task.tagIds) {
                var key = Std.string(tag);
                var t = props.tags.get(key);
                if (t != null) {
                    tags.push(jsx('<span key=$key className="uk-margin-small-bottom uk-margin-small-right">${if (null != t.russianName) t.russianName else t.name}</span> '));
                }
            }
        var problemUrl =
            if (task.isGymTask)
                Codeforces.getGymProblemUrl(task.codeforcesContestId, task.codeforcesIndex)
            else
                Codeforces.getProblemUrl(task.codeforcesContestId, task.codeforcesIndex);

        var labelStyle = switch(task.level) {
            case 1: " uk-label-success";
            case 3: " uk-label-warning";
            case 4 | 5: " uk-label-danger";
            default : "";
        };

        return jsx('
            <div key=${Std.string(task.id)} className="uk-margin">
                <div>
                    <a href=$problemUrl target="_blank">${task.name}</a> <span className=${"uk-label" + labelStyle}>${Std.string(task.level)}</span>
                    <span className="tags uk-margin-left uk-text-meta">$tags</span>
                    </div>
            </div>
        ');
    }

    function onFilterInputChanged() {
        dispatch(EditorAction.SetTasksFilter(refs.filterInput.value));
    }

    function startEditing(tagId: Float) {
        setState(copy(state, { editingTaskId: tagId }));
    }

    function saveEditing() {
        dispatch(EditorAction.UpdateTaskTags(
            state.editingTaskId,
            Lambda.array(
                Lambda.map(
                    if (refs.select.state.value != null) refs.select.state.value else [],
                    function(t) { return Std.parseFloat(t.value); }))
            )
        );
        setState(copy(state, { editingTaskId: null }));
    }

    function cancelEditing() {
        setState(copy(state, { editingTaskId: null }));
    }

    function onPaginatorChange(pageIndex: Int) {
        dispatch(EditorAction.SetTasksChunkIndex(pageIndex-1));
    }
}
