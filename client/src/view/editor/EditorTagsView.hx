package view.editor;

import utils.UIkit;
import messages.LinkTypes;
import Lambda;
import Std;
import haxe.EnumTools;
import action.EditorAction;
import js.html.InputElement;
import messages.TagMessage;
import messages.LinksForTagsMessage;
import action.TeacherAction;
import messages.AttemptMessage;
import messages.GroupMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import react.ReactComponent.ReactElement;
import utils.DateUtils;
import view.teacher.LoadingView;
import react.ReactUtil.copy;
import view.editor.NewTagView;
import utils.Select;
import haxe.EnumTools.EnumValueTools;

typedef EditorTagsProps = {
    tags: Array<TagMessage>,
    links: Array<LinksForTagsMessage>,
    update: TagMessage -> Void,
    insert: TagMessage -> Void,
    showNewTagView: Bool,
    linkId: String
}

typedef EditorTagsRefs = {
    filterInput: InputElement,
    edtingNameInput: InputElement,
    edtingRussianInput: InputElement,
    urlInput: InputElement,
    optionalInput: InputElement,
    editingUrlInput: InputElement,
    editingOptionalInput: InputElement,
    editingTypeSelected: Dynamic,
    typeSelected: Dynamic
}

typedef EditorTagsState = {
    filter: String,
    editingTagId: Float,
    editingLinkId: Float,
    url: String,
    optional: String
}

class EditorTagsView extends ReactComponentOfProps<EditorTagsProps> implements IConnectedComponent {

    public function new()
    {
        super();
        state = { filter: ""}
    }

    public function getAllLinkTypes(){
        var types = Type.allEnums(LinkTypes);
        var result = Lambda.array(Lambda.map(types, function(t){ return { value: EnumValueTools.getIndex(t), label: Std.string(EnumValueTools.getName(t))}; }));
        return result;
    }

    override function render() {
        if (props.tags != null) {
            var linkTypes = getAllLinkTypes();
            var editLink = if (props.links != null)
                [ for (l in props.links)
                        if (state.editingLinkId != null && l.id == state.editingLinkId && props.linkId != Std.string(l.id))
                            jsx('<table className="uk-container" key=${l.id}>
                                    <tr>
                                        <td>URL:</td>
                                        <td><input type="text" className="uk-input uk-margin-left" defaultValue=${l.url} ref="editingUrlInput"/></td>
                                    </tr>
                                    <tr>
                                        <td className="uk-margin-top">Описание:</td>
                                        <td><input type="text" className="uk-input uk-margin-left uk-margin-top" defaultValue=${l.optional} ref="editingOptionalInput"/></td>
                                    </tr>
                                    <tr>
                                        <td className="uk-margin-top">Тип:</td>
                                        <td className="uk-margin-top">
                                            <Select
                                                isMulti=${false}
                                                value=${linkTypes[l.type]}
                                                options=${linkTypes}
                                                ref="editingTypeSelected" className="uk-margin-left uk-margin-top"/></td>
                                    </tr>
                                </table>')] else [jsx('<div></div>')];
            var newLink = jsx('<div id="modalForm" data-uk-modal="${true}" key="1">
                                    <div className="uk-modal-dialog uk-margin-auto-vertical">
                                        <div className="uk-modal-body">
                                            <table className="uk-container">
                                                <tr>
                                                    <td>URL:</td>
                                                    <td><input type="text" className="uk-input uk-margin-left" ref="urlInput"/></td>
                                                </tr>
                                                <tr>
                                                    <td className="uk-margin-top">Описание:</td>
                                                    <td><input type="text" className="uk-input uk-margin-left uk-margin-top" ref="optionalInput"/></td>
                                                </tr>
                                                <tr>
                                                    <td className="uk-margin-top">Тип:</td>
                                                    <td>
                                                        <Select
                                                            isMulti=${false}
                                                            options=${linkTypes}
                                                            placeholder="Выберите тип ссылки"
                                                            ref="typeSelected" className="uk-margin-left uk-margin-top"/></td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div className="uk-modal-footer uk-text-right">
                                            <button className="uk-button uk-button-default uk-margin-left uk-modal-close" onClick=$cancelEditing>Отмена</button>
                                            <button className="uk-button uk-button-primary uk-margin-left uk-modal-close" type="button" onClick=$addLink>Сохранить</button>
                                        </div>
                                    </div>
                                </div>');
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
                        <tr>
                            <tr>
                                <td>Название на английском:</td>
                                <td><input type="text" className="uk-input uk-form-width-large" defaultValue=${t.name} ref="editingNameInput"/></td>
                            </tr>
                            <tr>
                                <td>Название на русском:</td>
                                <td><input type="text" className="uk-input uk-form-width-large" defaultValue=${t.russianName} ref="editingRussianNameInput"/></td>
                            </tr>
                            ${renderLinks(t.id)}
                                <button className="uk-button uk-button-primary uk-margin-bottom" onClick=$saveEditingTag>Сохранить</button>
                                <button className="uk-button uk-button-default uk-margin-left uk-margin-bottom" onClick=$cancelEditing>Отмена</button>
                        </tr>')
                    else
                        jsx('
                        <tr>
                            <td>${t.name}</td>
                            <td>${t.russianName}</td>
                            <td>${renderExistsLinks(t.id)}</td>
                            <td>
                                <div className="scholae-list-item-menu">
                                    <button className="uk-button uk-button-primary uk-margin-small-top uk-margin-left" onClick=${startTagEditing.bind(t.id)}>Изменить</button>
                                    <button className="uk-button uk-button-primary uk-margin-small-top uk-margin-left" onClick=${showModal.bind(t.id)}>Добавить ссылку</button>
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
                                    <th>Ссылки</th>
                                    <th className="uk-table-expand"></th>
                                </tr>
                            </thead>
                            <tbody>
                                $tags
                                $newLink
                                <div id="editForm" data-uk-modal="${true}">
                                    <div className="uk-modal-dialog uk-margin-auto-vertical">
                                        <div className="uk-modal-body">
                                            $editLink
                                            </div>
                                        <div className="uk-modal-footer uk-clearfix">
                                            <button className="uk-button uk-button-danger uk-margin-right uk-float-left uk-modal-close" onClick=$deleteLink><i data-uk-icon="trash"/>Удалить</button>
                                            <button className="uk-button uk-button-primary uk-float-right uk-modal-close" onClick=$updateLink>Изменить</button>
                                            <button className="uk-button uk-button-default uk-margin-right uk-float-right uk-modal-close" onClick=$cancelLink>Отмена</button>
                                        </div>
                                    </div>
                                </div>
                            </tbody>
                        </table>
                        $newTag
                    </div>
                ');
        } else {
            return jsx('<LoadingView description="Категории"/>');
        }
    }

    function renderLinks(tagId: Float){
        var linkTypes = getAllLinkTypes();
        var id = Std.string(tagId);
        var newLinks:Map <String, Array<ReactElement>> =
        if (props.links != null )
            [for (l in props.links) Std.string(l.tag) =>
                [for (li in props.links)
                    if(li.tag == state.editingTagId && props.linkId != Std.string(li.id))
                            jsx('
                                <tr key=${li.id}>
                                    <td><a href=${li.url}>${li.optional}</a>
                                    <button className="uk-margin-left" data-uk-icon="file-edit" onClick=${startEditingLink.bind(li.id)}></button></td>
                                </tr>
                            ')
                    else jsx('<div></div>')
                ]
            ]
        else ['0'=>[jsx('<div></div>')]];

        if (newLinks.exists(id)){
            return newLinks.get(id);
        } else return [];

    }

    function renderExistsLinks(tagId: Float){
        var id = Std.string(tagId);
        var links:Map <String, Array<ReactElement>> =
        if (props.links != null)
            [for (l in props.links) Std.string(l.tag) =>
                [for (li in props.links)
                    if(li.tag == tagId && Std.string(li.id) != props.linkId && state.editingLink == null)
                        jsx('
                            <tr key=${li.id}>
                                <td><a href=${li.url}>${li.optional}</a></td>
                            </tr>
                        ')
                ]
            ]
        else ['0'=>[jsx('<div></div>')]];

        if (links.exists(id)){
            return links.get(id);
        } else return [];
    }

    function showModal(tagId: Float){
        UIkit.modal("#modalForm").show();
        setState(copy(state, { editingTagId: tagId }));
    }

    function addLink(){
        var addType = refs.typeSelected.state.value;
       dispatch(EditorAction.InsertLink({
            id: null,
            tag: state.editingTagId,
            url: refs.urlInput.value,
            optional: refs.optionalInput.value,
            type: addType.value
        }));
        setState(copy(state, { editingTagId: null }));
        refs.urlInput.value = null;
        refs.optionalInput.value = null;
        addType.value = null;
    }

    function updateLink(){
        var updateType = refs.editingTypeSelected.state.value;
        dispatch(EditorAction.UpdateLink({
            id: state.editingLinkId,
            tag: state.editingTagId,
            url: refs.editingUrlInput.value,
            optional: refs.editingOptionalInput.value,
            type: updateType.value
        }));
    }

    function deleteLink(){
        dispatch(EditorAction.DeleteLink({
            id: state.editingLinkId,
            tag: null,
            url: null,
            optional: null,
            type: null
        }));

    }

    function startEditingLink(linkId: Float) {
        setState(copy(state, { editingLinkId: linkId }));
        UIkit.modal("#editForm").show();
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

    function cancelLink() {
        setState(copy(state,{ editingLinkId: null }));
    }

    function cancelEditing() {
        setState(copy(state, { editingTagId: null, editingLinkId: null }));
    }

    function onAddTagClick(e) {
        dispatch(EditorAction.ShowNewTagView);
    }

    function onCloseAddTagClick() {
        dispatch(EditorAction.HideNewTagView);
    }
}
