package view.editor;

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
                            <td><input type="text" className="uk-input" defaultValue=${t.name} ref="editingNameInput"/></td>
                            <td><input type="text" className="uk-input" defaultValue=${t.russianName} ref="editingRussianNameInput"/></td>
                            ${renderLinks(t.id)}
                            <tr>
                                <td><input type="text" placeholder="Новая ссылка" ref="urlInput"/></td>
                                <td><input type="text" placeholder="Описание" ref="optionalInput"/></td>
                            </tr>
                            <Select
                                    isMulti=${false}
                                    defaultValue=${linkTypes[0]}
                                    options=$${linkTypes}
                                    placeholder="Выберите тип ссылки"
                                    ref="typeSelected"/>
                                <button className="uk-button uk-button-primary" onClick=$addLink>Добавить ссылку</button>
                                <button className="uk-button uk-button-primary" onClick=$saveEditingTag>Сохранить</button>
                                <button className="uk-button uk-button-default uk-margin-left" onClick=$cancelEditing>Отмена</button>
                        </tr>')
                    else
                        jsx('
                        <tr>
                            <td>${t.name}</td>
                            <td>${t.russianName}</td>
                            ${renderExistsLinks(t.id)}
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
                                    <th>Ссылки</th>
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

    function renderLinks(tagId: Float){
        trace(props.links);
        var id = Std.string(tagId);
        var linkTypes = getAllLinkTypes();
        var newLinks:Map <String, Array<ReactElement>> =
        if (props.links != null )
            [for (l in props.links) Std.string(l.tag) =>
                [for (li in props.links)
                    if(li.tag == state.editingTagId)
                        if (state.editingLinkId != null && li.id == state.editingLinkId && props.linkId != Std.string(li.id))
                        jsx('
                            <div key=${li.id}>
                                <td><input type="text" defaultValue=${li.url} ref="editingUrlInput"/></td>
                                <td><input type="text" defaultValue=${li.optional} ref="editingOptionalInput"/></td>
                                <Select
                                        isMulti=${false}
                                        defaultValue=${linkTypes[li.type]}
                                        options=${linkTypes}
                                        ref="editingTypeSelected"/>
                                <button onClick=$updateLink>Готово</button>
                                <button onClick=$deleteLink>Удалить</button>
                                <button onClick=$cancelLink>Отменить</button>
                            </div>
                        ')
                        else if (props.linkId != Std.string(li.id))
                            jsx('
                                <div key=${li.id}>
                                    <td>${li.url}</td>
                                    <td>${li.optional}</td>
                                    <td>${EnumValueTools.getName(EnumTools.createByIndex(LinkTypes, li.type))}</td>
                                    <button onClick=${startEditingLink.bind(li.id)}>Изменить ссылку</button>
                                </div>
                            ')
                        else
                            jsx('<div></div>')
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
                    if(li.tag == tagId && Std.string(li.id) != props.linkId)
                        jsx('
                            <div key=${li.id}>
                                <td>${li.url}</td>
                                <td>${li.optional}</td>
                                <td>${EnumValueTools.getName(EnumTools.createByIndex(LinkTypes, li.type))}</td>
                            </div>
                        ')
                ]
            ]
        else ['0'=>[jsx('<div></div>')]];

        if (links.exists(id)){
            return links.get(id);
        } else return [];
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
        refs.urlInput.value = null;
        refs.optionalInput.value = null;
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
        setState(copy(state, { editingLinkId: null }));
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
