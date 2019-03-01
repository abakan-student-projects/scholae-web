package view;

import utils.DateUtils;
import achievement.AchievementCategory;
import haxe.EnumTools;
import haxe.EnumTools.EnumValueTools;
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

    override function render(): ReactElement {
        var cat = -1;
        var userAchievements: Array<ReactElement> = new Array<ReactElement>();
        if(props.achievements != null) {
                for (achievement in props.achievements) {
                    if(achievement.category == cat) {
                        userAchievements.push(renderAchievement(achievement));
                    } else {
                        cat = achievement.category;
                        userAchievements.push(renderAchievementCategory(cat));
                        userAchievements.push(renderAchievement(achievement));
                    }
                }
        } else null;
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
                    ${if(userAchievements == null) doesntLoading else if(userAchievements.length != 0) userAchievements else empty}
                </div>
            </div>
        ');
    }

    private function renderAchievementCategory(category: Int) {
        var category = EnumTools.createByIndex(AchievementCategory,category);
        var categoryName = EnumValueTools.getName(category);
        return jsx('<legend key=${category} className="uk-legend uk-width-2-3">$categoryName</legend>');
    }

    private function renderAchievement(achievement: AchievementMessage) {
        var imagesSrc = "../../images/"+achievement.icon;
        return jsx('
            <div key=${achievement.id} className="uk-card uk-card-small uk-width-2-3 uk-card-default uk-flex uk-flex-middle uk-margin-top uk-margin-bottom">
                <div className="uk-card-media-left uk-width-1-5 uk-text-center">
                    <img src="$imagesSrc" width="80" height="80"></img>
                </div>
                <div className="uk-card-body uk-padding-small uk-padding-remove-left uk-width-4-5 uk-flex uk-flex-column uk-text-left uk-flex-wrap">
                    <div className="uk-flex uk-flex-wrap uk-flex-middle uk-margin-small-bottom">
                        <div className="uk-width-3-5"><legend className="uk-legend">${achievement.title}</legend></div>
                        <div className="uk-width-2-5 uk-text-right">Дата получения: ${DateUtils.toString(achievement.date)}</div>
                    </div>
                    <div className="uk-width-1-1 uk-text-justify uk-margin-small-bottom">${achievement.description}</div>
                </div>
            </div>
        ');
    }
}
