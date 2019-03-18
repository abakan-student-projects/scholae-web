package view;

import haxe.crypto.Md5;
import messages.PasswordMessage;
import utils.UIkit;
import haxe.io.Input;
import messages.ProfileMessage;
import js.Browser;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactComponent.ReactElement;
import react.ReactMacro.jsx;

typedef UserProfileViewProps = {
    profile: ProfileMessage,
    sendActivationEmail: Void -> Void,
    updateEmail: ProfileMessage -> Void,
    updatePassword: PasswordMessage -> Void,
    updateProfile: ProfileMessage -> Void,
    cancel: Void -> Void
}

typedef UserProfileViewRefs = {
    email: InputElement,
    oldPassword: InputElement,
    newPassword: InputElement,
    confirmNewPassword: InputElement,
    codeforcesId: InputElement,
    firstName: InputElement,
    lastName: InputElement,
}

class UserProfileView extends ReactComponentOfPropsAndRefs<UserProfileViewProps, UserProfileViewRefs>  {
    public function new() {
        super();
    }

    override function componentDidMount() {
        if(props.profile != null) {
            updateRefsValue(props.profile);
        }
    }

    override function componentWillReceiveProps(nextProps) {
        if(nextProps.profile != null) {
            updateRefsValue(nextProps.profile);
        }
    }

    override function render(): ReactElement {
        var emailActivation = if(props.profile != null && props.profile.emailActivated) {
            jsx('
                <span className="uk-text-success uk-margin-left">Email активирован</span>
            ');
        } else if(props.profile != null){
            jsx('
                <span className="uk-text-warning uk-margin-left">
                    Email неактивирован. <a className="uk-link-text" onClick=$sendActivationEmail>Отправить письмо для активации.</a>
                </span>
            ');
        } else {
            jsx('<span></span>');
        }
        return jsx('
                <div>
                    <fieldset className="uk-fieldset">
                        <legend className="uk-legend">Редактирование email</legend>
                        <div className="uk-margin">
                            <input
                                className="uk-form-width-large uk-input"
                                type="text"
                                placeholder="Email"
                                ref="email"/>
                            ${emailActivation}
                        </div>
                        <div className="uk-margin ">
                            <button className="uk-form-width-large uk-button uk-button-primary" onClick=$onUpdateEmailClick>Обновить</button>
                        </div>
                        <hr className="uk-divider-icon uk-width-1-1"/>
                        <legend className="uk-legend">Редактирование пароля</legend>
                        <div className="uk-margin">
                            <input
                                className="uk-form-width-large uk-input"
                                type="password"
                                placeholder="Старый пароль"
                                ref="oldPassword"/>
                        </div>
                        <div className="uk-margin ">
                            <input
                                className="uk-form-width-large uk-input"
                                type="password"
                                placeholder="Новый пароль"
                                ref="newPassword"/>
                        </div>
                        <div className="uk-margin ">
                            <input
                                className="uk-form-width-large uk-input"
                                type="password"
                                placeholder="Подтверждение нового пароля"
                                ref="confirmNewPassword"/>
                        </div>
                        <div className="uk-margin ">
                            <button className="uk-form-width-large uk-button uk-button-primary" onClick=$onUpdatePasswordClick>Обновить</button>
                        </div>
                        <hr className="uk-divider-icon uk-width-1-1"/>
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
                            <button className="uk-form-width-large uk-button uk-button-primary" onClick=$onUpdateProfileClick>Обновить</button>
                        </div>
                        <div className="uk-margin ">
                            <button className="uk-form-width-large uk-button uk-button-default" onClick=$onCancelClick>Отмена</button>
                        </div>
                    </fieldset>
                </div>
            ');
    }

    private function updateRefsValue(profile: ProfileMessage) {
        refs.email.value = profile.email;
        refs.codeforcesId.value = profile.codeforcesHandle;
        refs.firstName.value = profile.firstName;
        refs.lastName.value = profile.lastName;
    }

    function sendActivationEmail(e) {
        props.sendActivationEmail();
    }

    function onUpdateEmailClick(e) {
        var regexp = ~/.+@.+\..+/i;
        if(regexp.match(refs.email.value)) {
            if(refs.email.value != props.profile.email && refs.email.value != "") {
                props.updateEmail({
                    userId: null,
                    email: refs.email.value,
                    firstName: null,
                    lastName: null,
                    codeforcesHandle: null,
                    emailActivated: true
                });
            }
        }
        else {
            UIkit.notification({
            message: "Некорректный формат почты", timeout: 5000, status: "warning"
            });
        }
    }

    function onUpdatePasswordClick(e) {
        if(refs.oldPassword.value != "" && refs.newPassword.value != "") {
            if(refs.newPassword.value == refs.confirmNewPassword.value) {
                props.updatePassword({
                    oldPassword: Md5.encode(refs.oldPassword.value),
                    newPassword: Md5.encode(refs.newPassword.value)
                });
            } else {
                UIkit.notification({
                    message: "Пароли не совпадают", timeout: 5000, status: "warning"
                });
            }
        } else {
            UIkit.notification({
                message: "Пароли не могут быть пустыми", timeout: 5000, status: "warning"
            });
        }

    }

    function onUpdateProfileClick(e) {
        var firstNameValue =
            if(refs.firstName.value != props.profile.firstName && refs.firstName.value != "") refs.firstName.value
            else null;
        var lastNameValue =
            if(refs.lastName.value != props.profile.lastName && refs.lastName.value != "") refs.lastName.value
            else null;
        var codeforcesHandleValue =
            if(refs.codeforcesId.value != props.profile.codeforcesHandle && refs.codeforcesId.value != "")
                refs.codeforcesId.value
            else null;
        props.updateProfile({
            userId: null,
            email: null,
            firstName: firstNameValue,
            lastName: lastNameValue,
            codeforcesHandle: codeforcesHandleValue,
            emailActivated: true
        });
    }

    function onCancelClick(e) {
        props.cancel();
    }
}
