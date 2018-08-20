package view;

import react.ReactComponent;
import react.ReactMacro.jsx;
import js.Browser;
import js.html.InputElement;

class RenewPasswordResponseView extends ReactComponent {

    public function new() {
        super();
    }

    override function render() {
        return jsx('<h2>На указанную вами почту мы отправили инструкцию по смене пароля.</h2>');
    }
}
