package model;

import messages.RatingMessage;
import utils.RemoteDataHelper;
import haxe.ds.StringMap;
import messages.TagMessage;
import messages.TrainingMessage;

import utils.RemoteData;

typedef LearnerState = {
    trainings: RemoteData<Array<TrainingMessage>>,
    resultsRefreshing: Bool,
    signup: {
        redirectTo: String
    },
    rating: RemoteData<RatingMessage>
}