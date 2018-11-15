package view;

import js.Browser;
import js.html.Location;
import action.ScholaeAction;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;

class StudentProjectScreen
    extends ReactComponentOfProps<RouteComponentProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return null;
    }

    override function componentDidMount(){
        Browser.location.href = "http://lambda-calculus.ru/blog/education/158.html";
    }
}
