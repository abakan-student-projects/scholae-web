package view.editor;

import action.EditorAction;
import js.html.InputElement;
import messages.TagMessage;
import action.TeacherAction;
import messages.AttemptMessage;
import messages.GroupMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import utils.DateUtils;
import view.teacher.LoadingView;
import react.ReactUtil.copy;
import view.editor.NewTagView;

typedef EditorTagsProps = {
    tags: Array<TagMessage>,
    update: TagMessage -> Void,
    insert: TagMessage -> Void,
    showNewTagView: Bool
}

typedef EditorTagsRefs = {
    filterInput: InputElement,
    edtingNameInput: InputElement,
    edtingRussianInput: InputElement
}

typedef EditorTagsState = {
    filter: String,
    editingTagId: Float
}

class EditorTagsView extends ReactComponentOfProps<EditorTagsProps> implements IConnectedComponent {

    public function new()
    {
        super();
        state = { filter: "" }
    }

    override function render() {
        if (props.tags != null) {
            var newTag =
                if (props.showNewTagView)
                    jsx('<NewTagView dispatch=${dispatch} close=$onCloseAddTagClick/>')
                else
                    jsx('<button className="uk-button uk-button-default" onClick=${onAddTagClick}>Добавить категорию</button>');

            var tags =
                [ for (t in Lambda.filter(
                        props.tags,
                        function(t) { return t.name.indexOf(state.filter) >= 0 || (null != t.russianName && t.russianName.indexOf(state.filter) >= 0);}
                    ))
                    if (state.editingTagId != null && state.editingTagId == t.id)
                        jsx('
                        <tr className="uk-margin" key=${t.id}>
                            <td><input type="text" className="uk-input" defaultValue=${t.name} ref="editingNameInput"/></td>
                            <td><input type="text" className="uk-input" defaultValue=${t.russianName} ref="editingRussianNameInput"/></td>
                            <td>
                                <button className="uk-button uk-button-primary" onClick=$saveEditingTag>Сохранить</button>
                                <button className="uk-button uk-button-default uk-margin-left" onClick=$cancelEditing>Отмена</button>
                            </td>
                        </tr>
                        ')
                    else
                        jsx('
                        <tr className="uk-margin scholae-list-item" key=${t.id}>
                            <td>${t.name}</td>
                            <td>${t.russianName}</td>
                            <td>
                                <div className="scholae-list-item-menu">
                                    <button className="uk-button uk-button-primary" onClick=${startTagEditing.bind(t.id)}>Изменить</button>
                                </div>
                            </td>
                        </tr>
                    ')
                ];
            return jsx('
                    <div id="tags">
                        <h2>Категории</h2>
                        <input type="text" className="uk-input uk-form-width-large" placeholder="Фильтр" ref="filterInput" value=${state.filter} onChange=$onFilterInputChanged />
                        <table className="uk-table uk-table-divider uk-table-middle uk-table-hover">
                            <thead>
                                <tr>
                                    <th>Название на английском</th>
                                    <th>Название на русском</th>
                                    <th className="uk-table-expand"></th>
                                </tr>
                            </thead>
                            <tbody>
                                $tags
                            </tbody>
                        </table>
                        $newTag
                    </div>
                ');
        } else {
            return jsx('<LoadingView description="Категории"/>');
        }
    }

    function onFilterInputChanged() {
        setState(copy(state, { filter: refs.filterInput.value }));
    }

    function startTagEditing(tagId: Float) {
        setState(copy(state, { editingTagId: tagId }));
    }

    function saveEditingTag() {
        props.update({
            id: state.editingTagId,
            name: refs.editingNameInput.value,
            russianName: refs.editingRussianNameInput.value
        });
        setState(copy(state, { editingTagId: null }));
    }

    function cancelEditing() {
        setState(copy(state, { editingTagId: null }));
    }

    function onAddTagClick(e) {
        dispatch(EditorAction.ShowNewTagView);
    }

    function onCloseAddTagClick() {
        dispatch(EditorAction.HideNewTagView);
    }
}
