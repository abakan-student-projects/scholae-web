package view;

import react.ReactComponent;
import react.ReactMacro.jsx;
import js.Browser;

typedef LearnerDashboardViewProps = {
    signIn: String -> Void
}

typedef LearnerDashboardViewRefs = {
}

class LearnerDashboardView extends ReactComponentOfPropsAndRefs<LearnerDashboardViewProps, LearnerDashboardViewRefs> {

    public function new()
    {
        super();
    }

    override function render() {
        return
            jsx('
           <div className="uk-height-1-1 uk-flex uk-flex-middle uk-flex-center" id="forget">
            <div>
                    <div className="uk-margin ">
                        <button className="uk-width-1-1 uk-button uk-button-primary uk-button-small " >Отправить</button>
            </div>
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
