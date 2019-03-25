package view.editor;

import haxe.ds.StringMap;
import Lambda;
import codeforces.Codeforces;
import messages.TagMessage;
import action.AdminAction;
import messages.TaskMessage;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import react.ReactUtil.copy;
import router.Link;
import utils.Bar;

typedef AdminAdaptiveProps = {
    tasks: Array<TaskMessage>,
    tags: Array<TagMessage>
}

typedef AdminAdaptiveRefs = {
    tasksCount: InputElement
}

typedef AdminAdaptiveState = {
    bar: Dynamic,
    i: Float
}

typedef ChartProps = {
    labels: Array<String>,
    datasets: Array<Dynamic>
}

typedef ChartAxis = {
    x: String,
    y: Float
}

class AdminAdaptiveView extends ReactComponentOfProps<AdminAdaptiveProps> implements IConnectedComponent {

    public function new()
    {
        super();
        state = {bar: data }
    }

    var data: ChartProps;
    var j: Float;
    var colors: Array<String>;

    function getColors() {
        var i = 0;
        var colors = [];
        while (i < 43) {
            colors.push('rgba(255,'+Math.floor(Math.random()*255)+',132,0.4)');
            i++;
        }
        return colors;
    }

    override function render() {
        colors = getColors();
        data = {
            labels: getTags(),
            datasets: [
                {
                    label:'Категории',
                    fill: false,
                    backgroundColor: 'rgba(255,99,132,1)',
                    borderColor: 'rgba(255,99,132,1)',
                    borderCapStyle: 'butt',
                    borderDashOffset: 0.0,
                    borderJoinStyle: 'miter',
                    hoverBackgroundColor: 'rgba(255,99,132,0.4)',
                    hoverBorderColor: 'rgba(255,99,132,1)',
                    data: [],
                }
            ]
        };
        if (props.tasks != null) {
            var tasks = [];
            var i = 1;
            for (t in props.tasks) {
                var problemUrl =
                    if (t.isGymTask)
                        Codeforces.getGymProblemUrl(t.codeforcesContestId, t.codeforcesIndex)
                    else
                        Codeforces.getProblemUrl(t.codeforcesContestId, t.codeforcesIndex);

                tasks.push(jsx('<tr>
                                    <td>${i++}</td>
                                    <td><Link to=$problemUrl target="_blank" className="uk-link-text">${t.name}</Link></td>
                                    <td>${renderTags(t)}</td>
                                    <td>${t.rating}</td>
                                </tr>'));
            }
            return jsx('
                    <div id="adaptiveDemo">
                        <input className="uk-input uk-width-small uk-margin-right" type="text" placeholder="Число" ref="tasksCount"/>
                        <button className="uk-button uk-button-default" onClick=$testAdaptive>Запуск</button>
                        <Bar data=${state.bar} />
                        <table className="uk-table uk-table-divider uk-table-middle uk-table-hover">
                            <thead>
                                <tr>
                                    <th>№</th>
                                    <th>Название</th>
                                    <th>Категории</th>
                                    <th>Рейтинг</th>
                                </tr>
                            </thead>
                            <tbody>
                            $tasks
                            </tbody>
                        </table>
                    </div>
                ');
        } else {
            return jsx('
                    <div id="adaptiveDemo">
                        <input className="uk-input uk-width-small uk-margin-right" type="text" placeholder="Число" ref="tasksCount"/>
                        <button className="uk-button uk-button-default" onClick=$testAdaptive>Запуск</button>
                        <Bar data=$data />
                        <table className="uk-table uk-table-divider uk-table-middle uk-table-hover">
                            <thead>
                                <tr>
                                    <th>№</th>
                                    <th>Название</th>
                                    <th>Категории</th>
                                    <th>Рейтинг</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                ');
        }

    }

    function testAdaptive() {
        setState({bar: data, i:0, prevData: []});
        dispatch(AdminAction.TestAdaptiveDemo(refs.tasksCount.value));
    }

    function renderTags(task: TaskMessage) {
        var tags = [];
        if (task != null && props.tags != null) {
            for (tag in props.tags) {
                for (t in task.tagIds) {
                    if (t == tag.id) {
                        tags.push(jsx('<span key=${tag.id} className="uk-margin-small-bottom uk-margin-small-right">${if (tag.russianName != null) tag.russianName else tag.name}</span>'));
                    }
                }
            }
        }
        return tags;
    }

    function getTags() {
        var tags = [];
        if (props.tags != null)
            for (t in props.tags)
                if (t.russianName != null)
                    tags.push(t.russianName);
                else if (t.name != null)
                    tags.push(t.name);
        return tags;
    }

    override function componentWillMount() {
        setState({bar: data, i: 0, prevData: [] });
    }

    override function componentDidMount() {
        var timer = new haxe.Timer(1000);
        timer.run = function() {
            var oldDataSet = data.datasets[0];
            var newData = [];
            var j = state.i;
            var data2 = new StringMap<Float>();
            j++;
            var i = 0;
            var prevData: Array<ChartAxis> = state.prevData;
            if (props.tasks != null) {
                for (t in props.tasks) {
                    i++;
                    if (i == j) {
                        for (label in data.labels) {
                            var data = new StringMap<Float>();
                            for (r in t.ratingByTag){
                                data.set(r.tagId, r.rating);
                            }
                            for (p in prevData) {
                                data2.set(p.x,p.y);
                            }
                            if (data.exists(label) && data2.exists(label)) {
                                newData.push({x: label, y: data.get(label) + data2.get(label)});
                            } else if (data.exists(label) && !(data2.exists(label))){
                                newData.push({x: label, y: data.get(label)});
                            } else if (data2.exists(label) && !(data.exists(label))) {
                                newData.push({x: label, y: data2.get(label)});
                            } else {
                                newData.push({x: label, y: 0});
                            }
                        }
                    }
                }
            }
            var newDataSet = {
                label:'Категории',
                fill:false,
                backgroundColor: colors,
                borderColor: 'rgba(255,99,132,1)',
                borderCapStyle: 'butt',
                borderDashOffset: 0.0,
                borderJoinStyle: 'miter',
                borderWidth: 1,
                hoverBackgroundColor: 'rgba(255,99,132,0.4)',
                hoverBorderColor: 'rgba(255,99,132,1)',
                data: newData
            };
            var newState = {
                labels: data.labels,
                datasets: [newDataSet]
            };
            setState({bar: newState, i: j, prevData: newData});
        };
    }

}
