import js.Browser;

import react.React;
import react.ReactDOM;
import react.ReactMacro.jsx;
import react.ReactComponent;

class App extends ReactComponent {

    static public function main() {
        ReactDOM.render(jsx('<App/>'), Browser.document.getElementById('app'));
    }

    public function new() {
        super();
    }

    override function render() {
        return jsx('
            <view.LoginForm/>
		');
    }
}