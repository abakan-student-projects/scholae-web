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
import utils.DateTimePicker;

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
    finishDate: Moment
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
            finishDate: Moment.moment({})
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
                    <label>Время начала:</label>
                    <div className="uk-margin">
                        <DateTimePicker className="uk-input" selected=${state.startDate}
                            locale="ru"
                            onChange=$onStartDateChanged
                            showTimeSelect=${true}
                            timeFormat="HH:mm"
                            timeIntervals={60}
                            dateFormat="LLL"
                         />
                     </div>
                </div>

                <div className="uk-margin">
                    <label>Время окончания:</label>
                    <div className="uk-margin">
                        <DateTimePicker className="uk-input" selected=${state.finishDate}
                            locale="ru"
                            onChange=$onFinishDateChanged
                            showTimeSelect=${true}
                            timeFormat="HH:mm"
                            timeIntervals={60}
                            dateFormat="LLL"
                         />
                     </div>
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
        props.create(refs.name.value, minLevel, maxLevel, tasksCount, tagIds,
                Date.fromTime(state.startDate.utc()),
                Date.fromTime(state.finishDate.utc()));
    }

    function onCancelClicked() {
        props.cancel();
    }

    function onStartDateChanged(date) {
        setState(copy(state, { startDate: date }));
    }

    function onFinishDateChanged(date) {
        setState(copy(state, { finishDate: date }));
    }
}
