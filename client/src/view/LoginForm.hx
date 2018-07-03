package view;

import react.ReactComponent;
import react.ReactMacro.jsx;

class LoginForm extends ReactComponent {
    override function render() {
        return jsx('
            <form>
                <fieldset class="uk-fieldset">

                    <legend class="uk-legend">Login</legend>

                    <div class="uk-margin">
                        <input class="uk-input" type="text" placeholder="E-mail"/>
                    </div>

                    <div class="uk-margin">
                        <input class="uk-input" type="password" placeholder="Password"/>
                    </div>

                </fieldset>
            </form>
		');
    }
}
