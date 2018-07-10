package view;

import react.ReactComponent;
import react.ReactMacro.jsx;

class LearnerDashboardScreen extends ReactComponent {

    public function new()
    {
        super();
    }

    override function render() {
        return jsx('
            <h1>Dashboard</h1>
		');
    }
}
