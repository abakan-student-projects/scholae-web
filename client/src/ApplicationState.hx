package ;

import model.Profile.ProfileState;
import model.AdminState;
import model.EditorState;
import model.LearnerState;
import model.TeacherState;
import model.Scholae;

typedef ApplicationState = {
    scholae: ScholaeState,
    teacher: TeacherState,
    learner: LearnerState,
    editor: EditorState,
    admin: AdminState,
    profile: ProfileState
}
