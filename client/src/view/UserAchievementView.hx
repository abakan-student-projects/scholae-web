package view;

import utils.StringUtils;
import js.Browser;
import js.html.HTMLDocument;
import js.html.URLSearchParams;
import achievement.AchievementUtils;
import utils.DateUtils;
import achievement.AchievementMessage;
import react.ReactComponent;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;
import utils.UIkit;

typedef UserAchievementViewProps = {
    achievements: Array<AchievementMessage>
}

class UserAchievementView extends ReactComponentOfProps<UserAchievementViewProps> {

    public function new() {
        super();
    }

    /*override function componentDidMount() {
        var elementID = new URLSearchParams(Browser.window.location.search).get("id");
        scrollToIdElement(elementID);
    }*/

    override function componentDidUpdate (prevProps: UserAchievementViewProps, prevState: Dynamic) {
        var elementID = new URLSearchParams(Browser.window.location.search).get("id");
        scrollToIdElement(elementID);
    }

    private inline function scrollToIdElement(id: String) {
        if (!StringUtils.isStringNullOrEmpty(id) && props.achievements != null)
            Browser.document.getElementById(id).scrollIntoView({behavior: "smooth", block: "center"});
    }

    override function render(): ReactElement {
        var userAchievements: Array<ReactElement> = new Array<ReactElement>();
        if(props.achievements != null && props.achievements.length != 0) {
            var lastCategoryNum = props.achievements[props.achievements.length-1].category + 1;
            for (category in 0...lastCategoryNum) {
                var achievementsByCategory: Array<AchievementMessage> =
                    props.achievements.filter(function(v: AchievementMessage) { return v.category == category; });
                if(achievementsByCategory.length != 0) {
                   userAchievements.push(renderAchievementCategory(category, achievementsByCategory));
                }
            }
        } else if(props.achievements == null) userAchievements = null;
        var doesntLoading = jsx('
                 <legend className="uk-legend uk-text-center">Данные не загружены</legend>
            ');
        var empty = jsx('
                 <legend className="uk-legend uk-text-center">Достижений пока нет.</legend>
            ');
        return jsx('
            <div>
                <div className="uk-flex uk-flex-center uk-flex-wrap uk-flex-wrap-middle">
                    <div className="uk-width-2-3"><h2>Достижения</h2></div>
                    <ul data-uk-accordion="multiple: true" className="achievements uk-width-2-3">
                        ${if(userAchievements == null) doesntLoading else if(userAchievements.length != 0) userAchievements else empty}
                    </ul>
                </div>
            </div>
        ');
    }

    private function renderAchievementCategory(category: Int, achievements: Array<AchievementMessage>) {
        var categoryName = AchievementUtils.getCategoryName(category);
        var userAchievements: Array<ReactElement> =
            [for (achievement in achievements) { renderAchievement(achievement); }];
        return jsx('
            <li key=${category} className="achievements uk-open">
                <a className="uk-accordion-title" href="#">$categoryName</a>
                <div className="uk-accordion-content">
                    $userAchievements
                </div>
            </li>
        ');
    }

    private function renderAchievement(achievement: AchievementMessage){
        var imagesSrc = "../../images/"+achievement.icon;
        return jsx('
            <div key=${achievement.id} id=${achievement.id} className="uk-card uk-card-small uk-card-default uk-flex uk-flex-middle uk-margin-top uk-margin-bottom">
                <div className="uk-card-media-left uk-width-1-5 uk-text-center">
                    <img src="$imagesSrc" width="80" height="80"></img>
                </div>
                <div className="uk-card-body uk-padding-small uk-padding-remove-left uk-width-4-5 uk-flex uk-flex-column uk-text-left uk-flex-wrap">
                    <legend className="uk-legend uk-margin-small-bottom">${achievement.title} ${if(achievement.grade != null) " - " + achievement.grade else null}</legend>
                    <div className="uk-width-1-1 uk-text-justify uk-margin-small-bottom">${achievement.description}</div>
                    <div className="uk-margin-small-bottom">Дата получения: ${DateUtils.toString(achievement.date)}</div>
                </div>
            </div>
        ');
    }
}
