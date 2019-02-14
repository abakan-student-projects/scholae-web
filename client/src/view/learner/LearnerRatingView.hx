package view.learner;

import haxe.ds.ArraySort;
import haxe.ds.StringMap;
import messages.TagMessage;
import messages.RatingMessage;
import action.LearnerAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import router.Link;


typedef LearnerRatingProps = {
    ?rating: RatingMessage,
    tags: Array<TagMessage>,
    ?allRating: Array<RatingMessage>,
    ?learnerId: Float
}

typedef LearnerRatingRefs = {

}

class LearnerRatingView
            extends ReactComponentOfPropsAndRefs<LearnerRatingProps, LearnerRatingRefs>
            implements IConnectedComponent {

    public function new()
    {
        super();
    }

    function getSortedNameTag(ratingCategory: Array<RatingCategory>) : Array<RatingCategory> {
        var nameTags: Array<RatingCategory> = [];
        for (t in props.tags) {
            for (ratingTags in ratingCategory) {
                if (t.id == ratingTags.id) {
                    if (t.russianName != null){
                        nameTags.push({ id: ratingTags.id, rating: ratingTags.rating, name: t.russianName  });
                    } else {
                        nameTags.push({ id: ratingTags.id, rating: ratingTags.rating, name: t.name  });
                    }

                }
            }
        }
        ArraySort.sort(nameTags, function(x: RatingCategory, y: RatingCategory) {return if ((x.rating == y.rating && x.name > y.name) || x.rating < y.rating) 1 else -1; });
        return nameTags;
    }
    var firstName: String;
    var lastName: String;
    var rating: ReactElement;
    var ratingResults: Array<ReactElement>;
    var ratingNullResults: Array<ReactElement>;
    var backGroup: ReactElement;
    var result: ReactElement;

    override function render() {
        var state: ApplicationState = context.store.getState();
        if (props.rating != null && props.tags != null){

            firstName = if (props.rating.learner.firstName != null) props.rating.learner.firstName else state.scholae.auth.firstName;
            lastName = if (props.rating.learner.lastName != null) props.rating.learner.lastName else state.scholae.auth.lastName;
            rating =  jsx('<h1>Рейтинг:${props.rating.rating}</h1>');

            var ratingNotNullCategory = [for (r in props.rating.ratingCategory)
                if (r.rating != 0) { id: r.id, rating: r.rating }];
            var ratingNotNullCategorySorted = getSortedNameTag(ratingNotNullCategory);
            ratingResults = [for (r in ratingNotNullCategorySorted)
                jsx('<tr key="${r.id}"><td>${r.name}</td><td><progress className="uk-progress" value=${r.rating} max="11000" key="${r.id}"></progress></td><td>${r.rating}</td></tr>')];

            var ratingNullCategory = [for (r in props.rating.ratingCategory)
                if (r.rating == 0) { id: r.id, rating: r.rating }];
            var ratingNullCategorySorted = getSortedNameTag(ratingNullCategory);
            ratingNullResults = [for (r in ratingNullCategorySorted)
                jsx('<tr key="${r.id}"><td>${r.name}</td><td><progress className="uk-progress" value=${r.rating} max="11000" key="${r.id}"></progress></td><td>${r.rating}</td></tr>')];

        } else if (props.allRating != null && props.tags != null && props.learnerId != null) {

            backGroup = jsx('<div className="uk-margin" key="1">
                                <Link to=${"/teacher/group/" + state.teacher.currentGroup.info.id + ""}>
                                    <span data-uk-icon="chevron-left"></span> ${state.teacher.currentGroup.info.name}
                                </Link>
                            </div>');
            for (userRating in props.allRating) {

                if (userRating.learner.id == props.learnerId) {

                    firstName = userRating.learner.firstName;
                    lastName = userRating.learner.lastName;
                    rating = jsx('<h1>Рейтинг:${userRating.rating}</h1>');

                    var ratingNotNullCategory = [for (r in userRating.ratingCategory)
                        if (r.rating != 0) { id: r.id, rating: r.rating }];
                    var ratingNotNullCategorySorted = getSortedNameTag(ratingNotNullCategory);
                    ratingResults = [for (r in ratingNotNullCategorySorted)
                        jsx('<tr key="${r.id}"><td>${r.name}</td><td><progress className="uk-progress" value=${r.rating} max="5" key="${r.id}"></progress></td><td>${r.rating}</td></tr>')];

                    var ratingNullCategory = [for (r in userRating.ratingCategory)
                        if (r.rating == 0) { id: r.id, rating: r.rating }];
                    var ratingNullCategorySorted = getSortedNameTag(ratingNullCategory);
                    ratingNullResults = [for (r in ratingNullCategorySorted)
                        jsx('<tr key="${r.id}"><td>${r.name}</td><td><progress className="uk-progress" value=${r.rating} max="5" key="${r.id}"></progress></td><td>${r.rating}</td></tr>')];
                }
            }
        } else {
            result = jsx('<div></div>');
        }
        return
            if (props.allRating!= null)
            jsx('
                <div key="rating">
                    $backGroup
                    <span data-uk-icon="user"></span> $firstName $lastName
                    $rating
                    <table className="uk-table uk-table-divider uk-table-hover">
                        <thead>
                            <tr>
                                <th className="uk-width-medium">Категория</th>
                                <th>Рейтинг</th>
                                <th className="uk-width-small">Значение</th>
                            </tr>
                        </thead>
                        <tbody>
                            $ratingResults
                            $ratingNullResults
                        </tbody>
                    </table>
                </div>
            ');
         else
                jsx('
                <div key="rating">
                    <span data-uk-icon="user"></span> $firstName $lastName
                    $rating
                    <table className="uk-table uk-table-divider uk-table-hover">
                        <thead>
                            <tr>
                                <th className="uk-width-medium">Категория</th>
                                <th>Рейтинг</th>
                                <th className="uk-width-small">Значение</th>
                            </tr>
                        </thead>
                        <tbody>
                            $ratingResults
                            $ratingNullResults
                        </tbody>
                    </table>
                </div>
            ');

    }
}