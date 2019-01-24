package view;

import messages.ProfileMessage;
import js.Browser;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;

typedef UserProfileViewProps = {
    profile: ProfileMessage,
    update: String -> String -> String  -> Void,
    cancel: Void -> Void
}

typedef UserProfileViewRefs = {
    codeforcesId: InputElement,
    firstName: InputElement,
    lastName: InputElement,
}

class UserProfileView extends ReactComponentOfPropsAndRefs<UserProfileViewProps, UserProfileViewRefs>  {
    public function new() {
        super();
    }

    override function componentWillReceiveProps(nextProps) {
        refs.codeforcesId.value = nextProps.profile.codeforcesHandle;
        refs.firstName.value = nextProps.profile.firstName;
        refs.lastName.value = nextProps.profile.lastName;
    }

    override function render(): ReactElement {
        return jsx('
                <div>
                    <fieldset className="uk-fieldset">
                        <legend className="uk-legend">Редактирование профиля</legend>

                        <div className="uk-margin">
                            <input
                                className="uk-form-width-large uk-input"
                                type="text"
                                placeholder= "Codeforces"
                                ref="codeforcesId"/>
                        </div>
                        <div className="uk-margin">
                            <input
                                className="uk-form-width-large uk-input"
                                type="text"
                                placeholder="Имя"
                                ref="firstName"/>
                        </div>
                        <div className="uk-margin">
                            <input
                                className="uk-form-width-large uk-input"
                                type="text"
                                placeholder="Фамилия"
                                ref="lastName"/>
                        </div>
                        <div className="uk-margin ">
                            <button className="uk-form-width-large uk-button uk-button-primary" onClick=$onUpdateClick>Обновить</button>
                        </div>
                        <div className="uk-margin ">
                            <button className="uk-form-width-large uk-button uk-button-default" onClick=$onCancelClick>Отмена</button>
                        </div>
                    </fieldset>
                </div>
            ');
    }

    function onUpdateClick(e) {
        props.update(refs.codeforcesId.value, refs.firstName.value, refs.lastName.value);
    }

    function onCancelClick(e) {
        props.cancel();
    }
}
