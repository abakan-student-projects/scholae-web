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
        <div>
        <div className="uk-grid uk-margin-left uk-margin-top uk-margin-right">
    	    <div className="uk-width-1-2 uk-flex-left"><a href=""><h1>SCHOLAE</h1></a></div>
    	    <div className="uk-width-1-2 uk-flex-right uk-text-right">
    	    <span className ="uk-margin-small-right" uk-icon="icon: user; ratio:1.5"></span>
    	    <a href="">Войти</a>
    	    </div>
        </div>
        <div className="uk-grid-divider"></div>
        <div className="uk-grid uk-margin-left uk-margin-top uk-margin-right">
    	    <div className="uk-width-1-3 data-uk-grid-margin uk-margin-left uk-padding-top uk-padding-remove uk-padding-right uk-padding-left">
    	    <h2> TRAINING NAME </h2>
                <div className="progress-bar-wrapper">
				    <progress id="progressbar" value="0" max="100"></progress>
				    <span className="progress-value">0%</span>
		        </div>
             </div>
         </div>
        <div className="show accomp uk-grid uk-margin-left uk-margin-top uk-margin-large-right uk-width-1-1 uk-background-default uk-animation-fade">
    	<div className="uk-width-1-2">
    	<div className=" uk-margin-top uk-margin-left uk-margin-right uk-padding-remove uk-margin-bottom">
    		<p><h3>TASK NAME</h3>
    		<span className="uk-margin-small-right" uk-icon="icon: star; ratio: 1"></span> </p>
    		<h4>TAGS</h4>
    	</div>
    	</div>
    	       	<div className="uk-width-1-2">
       <div  className="uk-flex-right uk-align-right uk-margin-large-right">
       	<p className="uk-margin">
       	<div className="uk-button-group">
    		<div className="uk-animation-toggle uk-margin-top but">
    			<button className="uk-button uk-button-primary uk-animation-kenburns uk-animation-fast"> Обновить </button>
    		</div>
    		<div className="uk-animation-toggle uk-margin-top but">
    			<button className="uk-button uk-button-primary uk-animation-kenburns uk-animation-fast"> Посмотреть условие </button>
    		</div>
			<div className="uk-animation-toggle uk-margin-top but">
    			<button className="uk-button uk-button-primary uk-animation-kenburns uk-animation-fast"> Послать решение </button>
    		</div>
    	</div>
    	</p>
    	</div>
    	</div>

    </div>
    <div className="show block uk-grid uk-margin-left uk-margin-top uk-margin-large-right uk-width-1-1 uk-background-default uk-animation-fade">
    	<div className="uk-width-1-2">
    	<div className=" uk-margin-top uk-margin-left uk-margin-right uk-padding-remove uk-margin-bottom">
    		<p><h3>TASK NAME</h3>
    		<span className="uk-margin-small-right" uk-icon="icon: star; ratio: 1"></span> </p>
    		<h4>TAGS</h4>
    	</div>
    	</div>
    	       	<div className="uk-width-1-2">
       <div  className="uk-flex-right uk-align-right uk-margin-large-right">
       	<p className="uk-margin">
       	<div className="uk-button-group">
    		<div className="uk-animation-toggle uk-margin-top but">
    			<button className="uk-button uk-button-primary uk-animation-kenburns uk-animation-fast"> Обновить </button>
    		</div>
    		<div className="uk-animation-toggle uk-margin-top but">
    			<button className="uk-button uk-button-primary uk-animation-kenburns uk-animation-fast"> Посмотреть условие </button>
    		</div>
			<div className="uk-animation-toggle uk-margin-top but">
    			<button className="uk-button uk-button-primary uk-animation-kenburns uk-animation-fast"> Послать решение </button>
    		</div>
    	</div>
    	</p>
    	</div>
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
