package ;

import model.EditorState;
import model.LearnerState;
import model.TeacherState;
import model.Scholae;

typedef ApplicationState = {
    scholae: ScholaeState,
    teacher: TeacherState,
    learner: LearnerState,
    editor: EditorState
}
