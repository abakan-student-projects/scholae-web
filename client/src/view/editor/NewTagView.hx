package view.editor;

import action.EditorAction;
import action.TeacherAction;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;

typedef NewTagProps = {
    close: Void -> Void
}

typedef NewTagRefs = {
    name: InputElement,
    russianName: InputElement
}

class NewTagView extends ReactComponentOfPropsAndRefs<NewTagProps, NewTagRefs> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {
        return jsx('
                <div id="new-tag">
                    <input className="uk-input uk-form-width-large uk-margin-right" ref="name" placeholder="English name"/>
                    <input className="uk-input uk-form-width-large uk-margin-right" ref="russianName" placeholder="Название по-русски"/>
                    <button className="uk-button uk-button-primary uk-margin-right" onClick=${onClick}>Создать</button>
                    <button className="uk-close-large" type="button" data-uk-close=${true} onClick=${props.close}></button>
                </div>
            ');
    }

    function onClick(e) {
        dispatch(EditorAction.InsertTag({
            id: null,
            name: refs.name.value,
            russianName: refs.russianName.value
        }));
        props.close();
    }
}
