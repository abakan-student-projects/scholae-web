package model;

import utils.RemoteDataHelper;
import messages.RatingMessage;
import Lambda;
import utils.IterableUtils;
import messages.TagMessage;
import haxe.ds.ArraySort;
import redux.StoreMethods;
import utils.RemoteDataHelper;
import messages.LearnerMessage;
import messages.GroupMessage;
import utils.RemoteData;
import action.TeacherAction;
import model.RegistrationState;
import model.Role.Roles;
import react.ReactUtil.copy;
import redux.IMiddleware;
import redux.IReducer;
import redux.StoreMethods;
import services.Session;
import services.TeacherServiceClient;
import utils.UIkit;

class Teacher
    implements IReducer<TeacherAction, TeacherState>
    implements IMiddleware<TeacherAction, ApplicationState> {

    public var initState: TeacherState = {
        groups: RemoteDataHelper.createEmpty(),
        currentGroup: null,
        showNewGroupView: false,
        tags: RemoteDataHelper.createEmpty(),
        lastLearnerAttempts: RemoteDataHelper.createEmpty(),
        assignmentCreating: false,
        trainingsCreating: false,
        resultsRefreshing: false,
        newAssignment: {
            possibleTasks: RemoteDataHelper.createEmpty()
        }
    };

    public var store: StoreMethods<ApplicationState>;

    public function new() {}

    public function reduce(state: TeacherState, action: TeacherAction): TeacherState {
        trace(action);
        return switch(action) {
            case Clear: initState;
            case LoadGroups: copy(state, { groups: copy(state.groups, RemoteDataHelper.createLoading()) });
            case LoadGroupsFinished(groups):
                copy(state, {
                    groups: RemoteDataHelper.createLoaded(groups),
                    showNewGroupView: false
                });
            case ShowNewGroupView:
                copy(state, {
                    showNewGroupView: true
                });
            case HideNewGroupView:
                copy(state, {
                    showNewGroupView: false
                });
            case AddGroup(name, signUpKey): copy(state, { loading: true });
            case GroupAdded(group):
                var nextState: TeacherState = copy(state, {
                    loading: false,
                });
                nextState.groups.data.push(group);
                nextState.showNewGroupView = false;
                nextState;

            case SetCurrentGroup(group):
                copy(state, { currentGroup: {
                    info: group,
                    learners: RemoteDataHelper.createLoading(),
                    assignments: RemoteDataHelper.createLoading()
                }});
            case LoadLearnersByGroupFinished(learners):
                copy(state, {
                    currentGroup: copy(state.currentGroup, {
                        learners: RemoteDataHelper.createLoaded(learners)
                    })
                });

            case LoadRatingLearnersByGroupFinished(rating):
                copy(state, {
                    currentGroup: copy(state.currentGroup, {
                        rating: RemoteDataHelper.createLoaded(rating)
                    })
                });

            case LoadAllTags: copy(state, { tags: RemoteDataHelper.createLoading() });
            case LoadAllTagsFinished(tags):
                copy(state, {
                    tags: RemoteDataHelper.createLoaded(tags)
                });

            case LoadLastLearnerAttempts: copy(state, { lastLearnerAttempts : RemoteDataHelper.createLoading() });
            case LoadLastLearnerAttemptsFinished(attempts):
                copy(state, {
                    lastLearnerAttempts: RemoteDataHelper.createLoaded(attempts)
                });

            case CreateAssignment(group, assignment): copy(state, { assignmentCreating: true });
            case CreateAssignmentFinished(assignment):
                if (state.currentGroup != null && state.currentGroup.info.id == assignment.groupId) {
                    copy(state, {
                        currentGroup: copy(state.currentGroup, {
                            assignments: RemoteDataHelper.createLoaded(
                                state.currentGroup.assignments.data.concat([assignment])
                            )
                        }),
                        assignmentCreating: false
                    });
                } else
                    copy(state, { assignmentCreating: false });

            case LoadAssignmentsByGroupFinished(assignments):
                copy(state, {
                    currentGroup: copy(state.currentGroup, {
                        assignments:  RemoteDataHelper.createLoaded(assignments)
                    })
                });

            case CreateTrainingsByMetaTrainings(groupId):
                copy(state, {
                    trainingsCreating: true
                });

            case CreateTrainingsByMetaTrainingsFinished(assignments):
                copy(state, {
                    trainingsCreating: false
                });

            case LoadTrainings(groupId):
                copy(state,
                {
                    currentGroup: copy(state.currentGroup,
                        {
                            trainings: RemoteDataHelper.createLoading(),
                            trainingsByAssignments: null
                        }
                    )
                });

            case LoadTrainingsFinished(trainings):
                copy(state,
                    {
                        currentGroup: copy(state.currentGroup,
                            {
                                trainings: RemoteDataHelper.createLoaded(trainings),
                                trainingsByUsersAndAssignments:
                                    IterableUtils.createStringMapOfArrays2(trainings,
                                                        function(t) { return Std.string(t.userId); },
                                                        function(t) { return Std.string(t.assignmentId); })
                            }
                        )
                    });

            case RefreshResults(groupId):
                copy(state,
                    {
                        resultsRefreshing: true
                    });

            case RefreshResultsFinished(trainings):
                copy(state,
                    {
                        resultsRefreshing: false,
                        currentGroup: copy(state.currentGroup,
                            {
                                trainings: RemoteDataHelper.createLoaded(trainings),
                                trainingsByUsersAndAssignments:
                                    IterableUtils.createStringMapOfArrays2(trainings,
                                        function(t) { return Std.string(t.userId); },
                                        function(t) { return Std.string(t.assignmentId); })
                            })
                    });

            case LoadPossibleTasks(metaTraining, filter):
                copy(state, { newAssignment: { possibleTasks: RemoteDataHelper.createLoading() }});

            case LoadPossibleTasksFinished(tasks):
                copy(state, { newAssignment: { possibleTasks: RemoteDataHelper.createLoaded(tasks) }});

            case DeleteLearnerFromCourse(learnerId, groupId): state;
            case DeleteLearnerFromCourseFinished(learnerId):
                copy(state, {
                    currentGroup: copy(state.currentGroup,
                        {
                            learners: { data: [for (l in state.currentGroup.learners.data) if (Std.parseFloat(Std.string(l.id)) != learnerId) l], loaded: true, loading: false}
                        })
                });

            case DeleteCourse(groupId): state;
            case DeleteCourseFinished(groupId):
                copy(state, {
                    groups: {
                        data: [for (g in state.groups.data) if (g.id != groupId) g],
                        loading: false,
                        loaded: true
                    }
                });
            case LoadRatingsForCourse(userIds, startDate, finishDate):
                copy(state, {
                    currentGroup: copy(state.currentGroup, {
                        rating:  RemoteDataHelper.createLoading()
                    })
                });
            case LoadRatingsForCourseFinished(rating):
                copy(state, {
                    currentGroup: copy(state.currentGroup, {
                        rating: RemoteDataHelper.createLoaded(rating)
                    })
                });

            case SortDeltaRatingByPeriod:
                ArraySort.sort(state.currentGroup.rating.data, function(x: RatingMessage, y:RatingMessage){ return if(x.ratingByPeriod < y.ratingByPeriod) 1 else -1; });
                copy(state, {
                    currentGroup: copy(state.currentGroup, {
                        rating:{data: [for (r in state.currentGroup.rating.data) r], loaded: true, loading: false }
                    })
                });

            case SortSolvedTasksByPeriod:
                ArraySort.sort(state.currentGroup.rating.data, function(x:RatingMessage, y:RatingMessage) { return if (x.solvedTasks < y.solvedTasks) 1 else -1; });
                copy(state, {
                   currentGroup: copy(state.currentGroup, {
                       rating: { data: [for (r in state.currentGroup.rating.data) r], loaded: true, loading: false }
                   })
                });

            case SortLearnersByPeriod:
                ArraySort.sort(state.currentGroup.rating.data, function(x:RatingMessage, y: RatingMessage)
                    { return if (x.learner.firstName > y.learner.firstName ||
                    (x.learner.lastName > y.learner.lastName && x.learner.firstName == y.learner.firstName)) 1 else -1; });
                copy(state, {
                    currentGroup: copy(state.currentGroup, {
                        rating: { data: [for (r in state.currentGroup.rating.data) r], loaded: true, loading: false }
                    })
                });
        }
    }

    public function middleware(action: TeacherAction, next:Void -> Dynamic) {
        trace(action);
        return switch(action) {
            case LoadGroups:
                TeacherServiceClient.instance.getAllGroups()
                    .then(function(groups) { store.dispatch(LoadGroupsFinished(groups)); });
                next();

            case AddGroup(name, signUpKey):
                TeacherServiceClient.instance.addGroup(name, signUpKey)
                    .then(function(group) { store.dispatch(GroupAdded(group)); });
                next();

            case GroupAdded(group):
                UIkit.notification({ message: "Создан новый курс '" + group.name + "'.", timeout: 3000 });
                next();

            case SetCurrentGroup(group):
                TeacherServiceClient.instance.getAllLearnersByGroup(group.id)
                    .then(function(learners) { store.dispatch(LoadLearnersByGroupFinished(learners)); });
                TeacherServiceClient.instance.getAssignmentsByGroup(group.id)
                    .then(function(assignments) { store.dispatch(LoadAssignmentsByGroupFinished(assignments)); });
                TeacherServiceClient.instance.getTrainingsByGroup(group.id)
                    .then(function(trainings) { store.dispatch(LoadTrainingsFinished(trainings)); });
                TeacherServiceClient.instance.getAllRating(group.id)
                    .then(function(rating) {
                        ArraySort.sort(rating, function(x: RatingMessage, y:RatingMessage)
                        { return
                            if (x.learner.firstName > y.learner.firstName ||
                            (x.learner.lastName > y.learner.lastName && x.learner.firstName == y.learner.firstName)) 1 else -1; });
                        store.dispatch(LoadRatingLearnersByGroupFinished(rating)); });
                next();

            case LoadAllTags:
                TeacherServiceClient.instance.getAllTags()
                    .then(function(tags) {
                        ArraySort.sort(tags, function(x: TagMessage, y: TagMessage) { return if (x.name > y.name) 1 else -1; });
                        store.dispatch(LoadAllTagsFinished(tags));
                    });
                next();

            case LoadLastLearnerAttempts:
                TeacherServiceClient.instance.getLastAttemptsForTeacher(10)
                    .then(function(attempts) {
                        store.dispatch(LoadLastLearnerAttemptsFinished(attempts));
                    });
                next();

            case CreateAssignment(group, assignment):
                TeacherServiceClient.instance.createAssignment(group, assignment)
                    .then(function(a) { store.dispatch(CreateAssignmentFinished(a)); });
                next();

            case CreateAssignmentFinished(assignment):
                UIkit.notification({ message: "Создан новый блок заданий '" + assignment.name + "'.", timeout: 3000 });
                store.dispatch(LoadTrainings(assignment.groupId));
                next();

            case CreateTrainingsByMetaTrainings(groupId):
                TeacherServiceClient.instance.createTrainingsByMetaTrainings(groupId)
                    .then(function(learners) { store.dispatch(CreateTrainingsByMetaTrainingsFinished(learners)); });
                next();

            case CreateTrainingsByMetaTrainingsFinished(assignments):
                UIkit.notification({ message: "Запрос на создание новых тренировок обработан.", timeout: 3000 });
                next();

            case LoadTrainings(groupId):
                TeacherServiceClient.instance.getTrainingsByGroup(groupId)
                    .then(function(trainings) { store.dispatch(LoadTrainingsFinished(trainings)); });
                next();

            case RefreshResults(groupId):
                TeacherServiceClient.instance.refreshResultsForGroup(groupId)
                    .then(function(trainings) { store.dispatch(RefreshResultsFinished(trainings)); });
                next();

            case RefreshResultsFinished(trainings):
                UIkit.notification({ message: "Результаты обновлены.", timeout: 3000 });
                next();

            case LoadPossibleTasks(metaTraining,filter):
                TeacherServiceClient.instance.getAllTasksByMetaTraining(metaTraining,filter)
                    .then(function(tasks) { store.dispatch(LoadPossibleTasksFinished(tasks)); });
                next();

            case DeleteLearnerFromCourse(learnerId, groupId):
                TeacherServiceClient.instance.deleteLearner(learnerId, groupId)
                    .then(function (learnerId) {store.dispatch(DeleteLearnerFromCourseFinished(learnerId)); });
                next();

            case DeleteLearnerFromCourseFinished(learner):
                UIkit.notification({ message: "Ученик удалён", timeout: 3000 });
                next();

            case DeleteCourse(groupId):
                TeacherServiceClient.instance.deleteCourse(groupId)
                    .then(function(groupId) { store.dispatch(DeleteCourseFinished(groupId)); });
                next();

            case DeleteCourseFinished(groupId):
                UIkit.notification({ message: "Курс удален", timeout: 3000 });
                next();

            case LoadRatingsForCourse(userIds, startDate, finishDate):
                TeacherServiceClient.instance.getRatingsForUsers(userIds, startDate, finishDate)
                    .then(function(rating) { store.dispatch(LoadRatingsForCourseFinished(rating)); });
                next();

            default: next();
        }
    }
}
