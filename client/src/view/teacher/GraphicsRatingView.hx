package view.teacher;

import haxe.ds.ArraySort;
import Array;
import messages.ArrayChunk;
import action.TeacherAction;
import utils.UIkit;
import messages.LearnerMessage;
import messages.RatingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.Link;
import utils.DateRangePicker;
import js.moment.Moment;
import utils.Select;
import react.ReactUtil.copy;
import utils.Line;

typedef GraphicsRatingProps = {
    learners: Array<LearnerMessage>,
    ratingForLine: Array<RatingMessage>
}

typedef GraphicsRatingState = {
    startDate: Moment,
    finishDate: Moment,
    focusedInput: Dynamic
}

typedef GraphicsRatingRefs = {
    select: Dynamic,
}

class GraphicsRatingView
            extends ReactComponentOfProps<GraphicsRatingProps>
            implements IConnectedComponent {

    public function new()
    {
        super();
        state = {
            startDate: null,
            finishDate: null,
        }
    }

    var Learners: Array<Float>;

    function getLearnersForSelect(){
        var learners = if (props.learners != null) Lambda.array(Lambda.map(props.learners, function(l){ return { value: l.id, label: l.firstName+" "+l.lastName}; })) else [];
        learners.sort(function(x, y) { return if (x.label < y.label) -1 else 1; });
        return learners;
    }

    function sortDates() {
        var sortedDates: Array<RatingDate> = [];
        var prevValue: RatingDate = null;
        var i = 1;
        if (props.ratingForLine != null) {
            for (r in props.ratingForLine) {
                for (r2 in r.ratingDate){
                    sortedDates.push({id: r2.id, date: r2.date, rating: r2.rating});
                }
            }
        }
        var length = sortedDates.length;
        var sortDatesFinished: Array<RatingDate> = [];
        for (s in sortedDates) {
            if (i == 1) {
                prevValue = s;
            } else {
                if (DateTools.format(prevValue.date,"%d.%m.%Y") == DateTools.format(s.date,"%d.%m.%Y")) {
                    if (i == length) {
                        sortDatesFinished.push(s);
                    } else {
                        prevValue = s;
                    }
                } else {
                    if (i == length) {
                        sortDatesFinished.push(prevValue);
                        sortDatesFinished.push(s);
                    } else {
                        sortDatesFinished.push(prevValue);
                        prevValue = s;
                    }
                }
            }
            i++;
        }
        return sortDatesFinished;
    }

    override function render() {
        var colours = ['rgb(247, 17, 17)','rgb(232, 109, 166)',
                        'rgb(222, 88, 232)','rgb(167, 88, 232)',
                        'rgb(70, 62, 214)','rgb(62, 207, 214)',
                        'rgb(40, 247, 81)','rgb(237, 247, 40)',
                        'rgb(247, 154, 40)','rgb(242, 161, 138)'];
        var learners = getLearnersForSelect();
        var datesForChart = sortDates();
        var coloursMap: Map<Int,String> = if (props.ratingForLine != null) [for (r in props.ratingForLine)
                                            Std.parseInt(Std.string(r.learner.id)) => colours.shift()] else [0 => 'null'];
        var data = {
            labels: [ for (d in datesForChart) DateTools.format(d.date,"%d.%m.%Y")],
            datasets: if (props.ratingForLine != null) [for (l in props.ratingForLine)
                {
                    label: l.learner.firstName+" "+l.learner.lastName,
                    fill: false,
                    lineTension: 0.1,
                    backgroundColor: coloursMap.get(Std.parseInt(Std.string(l.learner.id))),
                    borderColor: coloursMap.get(Std.parseInt(Std.string(l.learner.id))),
                    borderCapStyle: 'butt',
                    borderDashOffset: 0.0,
                    borderJoinStyle: 'miter',
                    pointBackgroundColor: '#fff',
                    pointBorderWidth: 1,
                    pointHoverRadius: 5,
                    pointHoverBorderWidth: 2,
                    pointRadius: 3,
                    pointHitRadius: 10,
                    data: [for (r in l.ratingDate) {x: DateTools.format(r.date,"%d.%m.%Y"), y:r.rating}]}]
            else []
        };
        return jsx('
                    <div>
                        <h2>Построение графика</h2>
                        <div className="uk-margin-small">
                            <label>Ученики</label>
                        </div>
                        <Select
                            isMulti=${true}
                            isLoading=${learners == null || learners.length <= 0}
                            options=$learners
                            onChange=$onSelectedLearnersChanged
                            placeholder="Выберите учеников..."
                            ref="select"/>
                        <div className="uk-margin">
                            <div className="uk-margin-small">
                                <label>Период</label>
                            </div>
                            <DateRangePicker
                                isOutsideRange=${function(){ return false; }}
                                displayFormat="LL"
                                startDate=${state.startDate}
                                startDateId="rating-startDate"
                                startDatePlaceholderText="От"
                                endDate=${state.finishDate}
                                endDateId="rating-endDate"
                                endDatePlaceholderText="До"
                                onDatesChange=${function(range) { setState(copy(state, { startDate: range.startDate, finishDate: range.endDate })); }}
                                focusedInput=${state.focusedInput}
                                onClose=${function(){if (state.finishDate != null) renderChart();}}
                                onFocusChange=${function(focusedInput) { setState(copy(state,{ focusedInput: focusedInput }));}}/>
                        </div>
                        <div className="uk-margin-small">
                            <Line data=${data} />
                        </div>
                    </div>');
    }

    function renderChart(){
        var startDate: Date = Date.fromTime(state.startDate.utc());
        var finishDate: Date = Date.fromTime(state.finishDate.utc());
        dispatch(TeacherAction.LoadRatingsForCourse(Learners,
        new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), 0 , 0, 0),
        new Date(finishDate.getFullYear(), finishDate.getMonth(), finishDate.getDate(), 23 , 59, 59)));
    }

    function onSelectedLearnersChanged(learners) {
        Learners = if (learners != null) Lambda.array(Lambda.map( learners, function(l) {return l.value; })) else [];
        if (state.finishDate != null) {
            renderChart();
        }
    }

}