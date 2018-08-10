package view.teacher;

import js.moment.Moment;
import js.html.InputElement;
import action.TeacherAction;
import messages.TagMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import utils.DateRangePicker;

import react.ReactUtil.copy;

typedef TeacherNewAssignmentProps = {
    tags: Array<TagMessage>,
    create: String -> Int -> Int -> Int -> Array<Float> -> Date -> Date -> Void,
    cancel: Void -> Void
}

typedef TeacherNewAssignmentRefs = {
    name: InputElement
}

typedef TeacherNewAssignmentState = {
    startDate: Moment,
    finishDate: Moment,
    focusedInput: Dynamic
}

class TeacherNewAssignmentView extends ReactComponentOfPropsAndRefs<TeacherNewAssignmentProps, TeacherNewAssignmentRefs> implements IConnectedComponent {

    var minLevel: Int;
    var maxLevel: Int;
    var tasksCount: Int;
    var tagIds: Array<Float>;

    public function new() {
        super();
        state = {
            startDate: Moment.moment({}),
            finishDate: null
        };
    }

    override function render() {
        return jsx('
            <div className="uk-margin uk-margin-left">
                <h1>Создание нового блока заданий</h1>
                <div className="uk-margin">
                    <input className="uk-input" type="text" placeholder="Название" ref="name"/>
                </div>

                <div className="uk-margin">
                    <div className="uk-margin-small">
                        <label>Сроки выполнения:</label>
                    </div>
                    <DateRangePicker
                        displayFormat="LL"
                        startDate=${state.startDate}
                        startDateId="new-assignment-startdate"
                        startDatePlaceholderText="Дата начала"
                        endDate=${state.finishDate}
                        endDateId="new-assignment-enddate"
                        endDatePlaceholderText="Дата окончания"
                        onDatesChange=${function(range) { setState(copy(state, { startDate: range.startDate, finishDate: range.endDate })); }}
                        focusedInput=${state.focusedInput}
                        onFocusChange=${function(focusedInput) { setState(copy(state, { focusedInput: focusedInput })); }}
                    />
                </div>

                <TrainingParametersView tags=${props.tags} onTagsChanged=$onTrainingTagsChanged onChanged=$onTrainingChanged/>

                <p className="uk-margin">
                    <button className="uk-button uk-button-primary uk-margin-right" onClick=$onCreateClicked>Создать</button>
                    <button className="uk-button uk-button-default" onClick=$onCancelClicked>Отмена</button>
                </p>
            </div>
        ');
    }

    function onTrainingTagsChanged(checkedTagIds: Array<Float>) {
        tagIds = checkedTagIds;
    }

    function onTrainingChanged(minLevel: Int, maxLevel: Int, tasksCount: Int) {
        this.minLevel = minLevel;
        this.maxLevel = maxLevel;
        this.tasksCount = tasksCount;
    }

    function onCreateClicked() {
        var startDate: Date = Date.fromTime(state.startDate.utc());
        var finishDate: Date = Date.fromTime(state.finishDate.utc());
        props.create(refs.name.value, minLevel, maxLevel, tasksCount, tagIds,
                new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), 0 , 0, 0),
                new Date(finishDate.getFullYear(), finishDate.getMonth(), finishDate.getDate(), 23 , 59, 59));
    }

    function onCancelClicked() {
        props.cancel();
    }
}
