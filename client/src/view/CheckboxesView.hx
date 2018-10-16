package view;

import haxe.ds.StringMap;
import js.html.InputElement;
import messages.TagMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;

typedef CheckboxData = {
    id: String,
    label: Dynamic,
    checked: Bool
}

typedef CheckboxesProps = {
    data: Array<CheckboxData>,
    onChanged: Array<String> -> Void
}

typedef CheckboxesState = {
    checkedIds: StringMap<Bool>
}

class CheckboxesView extends ReactComponentOfPropsAndState<CheckboxesProps, CheckboxesState> {

    public function new()
    {
        super();
        state = { checkedIds: new StringMap<Bool>() };
    }

    override function render() {
        var items = props.data.map(function(c) {
            return jsx('
                <div key=${c.id}>
                    <label>
                        <input
                            className="uk-checkbox"
                            type="checkbox"
                            checked=${state.checkedIds.exists(c.id)}
                            onChange=${toggleCheckbox.bind(c.id)}
                        />
                        &nbsp;
                        ${c.label}
                    </label>
                </div>
            ');
        });

        return jsx('
            <div>
                <button className="uk-button uk-button-default uk-button-small" onClick=$selectAll>Выбрать все</button>
                <button className="uk-button uk-button-default uk-button-small" onClick=$deselectAll>Исключить все</button>
                <div className="uk-margin">
                    $items
                </div>
            </div>
        ');
    }

    override function componentDidMount() {
        var checked = new StringMap<Bool>();
        for (c in props.data) {
            if (c.checked) {
                checked.set(c.id, true);
            }
        }
        setState({
            checkedIds: checked
        });
    }

    function toggleCheckbox(id) {
        if (state.checkedIds.exists(id)) {
            state.checkedIds.remove(id);
        } else {
            state.checkedIds.set(id, true);
        }
        setState(state, onChanged);
    }

    function selectAll() {
        var checked = new StringMap<Bool>();
        for (c in props.data) {
            checked.set(c.id, true);
        }
        setState({
            checkedIds: checked
        }, onChanged);
    }

    function deselectAll() {
        setState({
            checkedIds: new StringMap<Bool>()
        }, onChanged);
    }

    function onChanged() {
        var array = [];
        for (id in state.checkedIds.keys()) {
            array.push(id);
        }
        props.onChanged(array);
    }

}
