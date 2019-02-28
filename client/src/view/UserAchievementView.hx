package view;

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
        trace(props.achievements);
        var userAchievements = if(props.achievements != null)[for (achievement in props.achievements) renderAchievement(achievement)];
        else null;
        var doesntLoading = jsx('
                 <legend className="uk-legend uk-text-center">Data was not loaded</legend>
            ');
        return jsx('
            <div>
                <div className="uk-flex uk-flex-center uk-flex-wrap uk-flex-wrap-middle">
                <div className="uk-width-2-3 uk-margin-bottom"><legend className="uk-legend">Достижения</legend></div>
                    ${if(userAchievements != null) userAchievements else doesntLoading}
                </div>
            </div>
        ');
    }

    private function renderAchievement(achievement: AchievementMessage) {
        return jsx('
            <div key=${achievement.id} className="uk-card uk-width-2-3 uk-card-small uk-card-default uk-flex uk-flex-middle uk-margin-top uk-margin-bottom">
                <div className="uk-card-media-left uk-width-1-6 uk-margin-left uk-text-center">
                    <span className="uk-margin-small-right" data-uk-icon="${achievement.icon}"></span>
                </div>
                <div className="uk-card-body uk-width-5-6 uk-flex uk-flex-column uk-text-left uk-flex-wrap">
                    <div className="uk-flex uk-flex-wrap">
                        <div className="uk-width-2-3"><legend className="uk-legend">${achievement.title}</legend></div>
                        <div className="uk-width-1-3">Дата получения: ${achievement.date}</div>
                    </div>

                    <div className="uk-width-1-1">${achievement.description}</div>
                </div>
            </div>
        ');
    }
}
