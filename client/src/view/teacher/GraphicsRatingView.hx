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
        var endDate: Date = null;
        if (state.finishDate != null) {
            endDate = Date.fromTime(state.finishDate.utc());
            endDate = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate(), 23 , 59, 59);
        }
        if (props.ratingForLine != null) {
            for (r in props.ratingForLine) {
                for (r2 in r.ratingDate){
                    var day = ((r2.date.getFullYear() - 2010 - 1) * 12 + r2.date.getMonth()) * 31 + r2.date.getDate();
                    var finishDay = ((endDate.getFullYear() - 2010 - 1) * 12 + endDate.getMonth()) * 31 + endDate.getDate();
                    if (day != finishDay) {
                        sortedDates.push({id: r2.id, date: r2.date, rating: r2.rating});
                    }
                }
            }
        }
        sortedDates.push({id:0, date: endDate, rating: 0});
        ArraySort.sort(sortedDates, function(x: RatingDate, y: RatingDate) { return if
        ((x.date.getDate() > y.date.getDate()) && (x.date.getMonth() == y.date.getMonth()) && (x.date.getFullYear() == y.date.getFullYear())
        || (x.date.getMonth() > y.date.getMonth()) || (x.date.getFullYear() > y.date.getFullYear())) 1 else -1;});
        var sortedDatesFinished: Array<Date> = [];
        var prevData: RatingDate = null;
        var i = 1;
        for (s in sortedDates) {
            if (i == 1) {
                prevData = s;
            } else {
                if (DateTools.format(prevData.date, "%d.%m.%Y") == DateTools.format(s.date, "%d.%m.%Y")){
                    prevData = s;
                    if (i == sortedDates.length)
                        sortedDatesFinished.push(prevData.date);
                } else {
                    sortedDatesFinished.push(prevData.date);
                    prevData = s;
                    if (i == sortedDates.length)
                        sortedDatesFinished.push(s.date);
                }
            }
            i++;
        }
        return sortedDatesFinished;
    }

    override function render() {
        var colours = ['rgb(0, 250, 154)','rgb(102, 205, 170)',
                        'rgb(0, 139, 139)','rgb(0, 206, 209)',
                        'rgb(123, 104, 238)','rgb(65, 105, 225)',
                        'rgb(147, 112, 219)','rgb(153, 50, 204)',
                        'rgb(106, 90, 205)','rgb(188, 143, 143)'];
        var learners = getLearnersForSelect();
        var datesForChart = sortDates();
        var coloursMap: Map<Int,String> = if (props.ratingForLine != null) [for (r in props.ratingForLine)
                                            Std.parseInt(Std.string(r.learner.id)) => colours.shift()] else [0 => 'null'];
        var data = {
            labels: [ for (d in datesForChart) DateTools.format(d, "%d.%m.%Y") ],
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
                    data: [for (r in l.ratingDate) {x: DateTools.format(r.date, "%d.%m.%Y"), y: r.rating} ]}]
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