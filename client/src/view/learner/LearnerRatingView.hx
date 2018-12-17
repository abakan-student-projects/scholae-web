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

typedef LearnerRatingProps = {
    rating: RatingMessage,
    tag: Array<TagMessage>
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
        for (t in props.tag) {
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

    override function render() {
        var result;
        if (props.rating != null && props.tag != null){
            var state: ApplicationState = context.store.getState();
            var firstName = if (props.rating.learner.firstName != null) props.rating.learner.firstName else state.scholae.auth.firstName;
            var lastName = if (props.rating.learner.lastName != null) props.rating.learner.lastName else state.scholae.auth.lastName;
            var rating =  jsx('<h1>Рейтинг:${props.rating.rating}</h1>');
            var ratingNotNullCategory = [for (r in props.rating.ratingCategory)
                if (r.rating != 0) { id: r.id, rating: r.rating }];
            var ratingNotNullCategorySorted = getSortedNameTag(ratingNotNullCategory);
            var ratingResults = [for (r in ratingNotNullCategorySorted)
                jsx('<tr><td>${r.name}</td><td><progress className="uk-progress" value=${r.rating} max="11000"></progress></td><td>${r.rating}</td></tr>')];
            var ratingNullCategory = [for (r in props.rating.ratingCategory)
                if (r.rating == 0) { id: r.id, rating: r.rating }];
            var ratingNullCategorySorted = getSortedNameTag(ratingNullCategory);
            var ratingNullResults = [for (r in ratingNullCategorySorted)
                jsx('<tr><td>${r.name}</td><td><progress className="uk-progress" value=${r.rating} max="11000"></progress></td><td>${r.rating}</td></tr>')];

            result = jsx('
                <div key="rating">
                    <div className="uk-margin">
                        <Link to=${"/teacher/group/" + state.teacher.currentGroup.info.id + ""}><span data-uk-icon="chevron-left"></span> ${state.teacher.currentGroup.info.name} </Link>
                    </div>
                    <span data-uk-icon="user"></span> $firstName $lastName
                    $rating
                    <table className="uk-table uk-table-divider uk-table-hover">
                        <thead>
                            <tr>
                                <th className="uk-width-medium">Категории</th>
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
        } else {
            result = jsx('<div></div>');
        }
        return result;
    }
}