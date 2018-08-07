package view.teacher;

import codeforces.Codeforces;
import messages.ExerciseMessage;
import haxe.ds.ArraySort;
import haxe.ds.StringMap;
import messages.AssignmentMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.Link;

typedef TeacherTrainingProps = {
    group: GroupMessage,
    training: TrainingMessage,
    tags: StringMap<TagMessage>
}

class TeacherTrainingView extends ReactComponentOfProps<TeacherTrainingProps> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {

        if (null != props.training && null != props.group) {

            var exercises = [for (e in props.training.exercises) renderExerciseRow(e)];

            return jsx('
                    <div className="training">
                        <Link to=${"/teacher/group/" + props.group.id}><span data-uk-icon="chevron-left"></span>${props.group.name}</Link>
                        <h1>${props.training.name}</h1>
                        <div className="exercises">$exercises</div>
                    </div>
                ');
        } else {
            return jsx('<LoadingView description="Тренировка"/>');
        }
    }

    function renderExerciseRow(exercise: ExerciseMessage) {

        var tags = [];
        for (tag in exercise.task.tagIds) {
            var key = Std.string(tag);
            var t = props.tags.get(key);
            if (t != null) {
                tags.push(jsx('<span key=$key>${t.name}</span> '));
            }
        }
        var problemUrl =
            if (exercise.task.isGymTask)
                Codeforces.getGymProblemUrl(exercise.task.codeforcesContestId, exercise.task.codeforcesIndex)
            else
                Codeforces.getProblemUrl(exercise.task.codeforcesContestId, exercise.task.codeforcesIndex);

        var solvedMark = if (exercise.task.isSolved) jsx('<span data-uk-icon="check"></span>') else jsx('<span></span>');

        return jsx('
            <div key=${Std.string(exercise.id)}>
                <h2><a href=$problemUrl target="_blank">${exercise.task.name}</a> <span className="uk-badge">${Std.string(exercise.task.level)}</span> $solvedMark</h2>
                <div className="tags">$tags</div>
            </div>
        ');
    }
}
