package view;

import react.ReactComponent;
import react.ReactMacro.jsx;
import js.Browser;
import js.html.InputElement;




class RenewPasswordResponseView extends ReactComponent {

    public function new()
    {
        super();
    }

    override function render() {
        return
            jsx('

           <div class="uk-height-1-1 uk-flex uk-flex-middle uk-flex-center">
            <div>
            		  <p class="uk-text "><big>На указанную вами почту мы отправили инструкцию по смене пароля.</big></p>
            </div>
           </div>

            ');
    }

    override function componentDidMount() {
        Browser.document.body.classList.toggle("uk-height-1-1", true);
    }

    override function componentWillUnmount() {
        Browser.document.body.classList.remove("uk-height-1-1");
    }

}