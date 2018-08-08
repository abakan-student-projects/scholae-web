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
    learner: LearnerMessage,
    tags: StringMap<TagMessage>
}

class TeacherTrainingView extends ReactComponentOfProps<TeacherTrainingProps> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {

        if (null != props.training && null != props.group && null != props.learner) {

            var exercises = [for (e in props.training.exercises) renderExerciseRow(e)];

            return jsx('
                    <div className="training">
                        <div className="uk-margin">
                            <Link to=${"/teacher/group/" + props.group.id}><span data-uk-icon="chevron-left"></span>${props.group.name}</Link>
                        </div>
                        <h2 className="uk-margin-remove">${props.training.name}</h2>
                        <h3 className="uk-margin-remove">${props.learner.lastName} ${props.learner.firstName}</h3>
                        <div className="exercises uk-margin-top">$exercises</div>
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
                tags.push(jsx('<span key=$key className="uk-margin-small-bottom uk-margin-small-right">${t.name}</span> '));
            }
        }
        var problemUrl =
            if (exercise.task.isGymTask)
                Codeforces.getGymProblemUrl(exercise.task.codeforcesContestId, exercise.task.codeforcesIndex)
            else
                Codeforces.getProblemUrl(exercise.task.codeforcesContestId, exercise.task.codeforcesIndex);

        var solvedMark = if (exercise.task.isSolved) jsx('<span className="uk-margin-left" data-uk-icon="check"></span>') else jsx('<span></span>');

        var labelStyle = switch(exercise.task.level) {
            case 1: " uk-label-success";
            case 3: " uk-label-warning";
            case 4 | 5: " uk-label-danger";
            default : "";
        };

        return jsx('
            <div key=${Std.string(exercise.id)} className="uk-margin">
                <div>
                    <a href=$problemUrl target="_blank">${exercise.task.name}</a> <span className=${"uk-label" + labelStyle}>${Std.string(exercise.task.level)}</span>
                    $solvedMark
                    <span className="tags uk-margin-left uk-text-meta">$tags</span>
                    </div>
            </div>
        ');
    }
}
