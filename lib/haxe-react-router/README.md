# React-router externs for Haxe

Simple externs for [react-router](https://github.com/ReactTraining/react-router) 3.0.0+ (not 4!)
for use with [Haxe react](https://github.com/massiveinteractive/haxe-react) 1.0.0+.

```haxe
  var history = ReactRouter.browserHistory;

  var app = ReactDOM.render(jsx('
  
    <Router history=$history>
      <Route path="/" component=$PageWrapper>
        <IndexRoute component=$HomeView/>
        <Route path="about" component=$AboutView/>
      </Route>
    </Router>
      
  '), rootElement);
```

Using [haxe-modular](https://github.com/elsassph/haxe-modular) it is possible to define asynchronous routes:

```haxe
  var history = ReactRouter.browserHistory;

  var app = ReactDOM.render(jsx('

    <Router history=$history>
      <Route path="/" component=$PageWrapper>
        <IndexRoute getComponent=${RouteBundle.load(HomeView)}/>
        <Route path="about" getComponent=${RouteBundle.load(AboutView)}/>
      </Route>
    </Router>

  '), rootElement);
````

## Tips

### Q. how to use a High-Order Component with a modular route?

You must apply your HOC after the class is loaded.

To keep using `RouteBundle.load` you can wrap the view with a container:

```haxe
<Route path="login" getComponent=${RouteBundle.load(LoginContainer)} />

class LoginContainer extends ReactComponent {
    static var LoginViewWithRouter = withRouter(LoginView); // HOC
    override function render() {
        return jsx('<LoginViewWithRouter {...props} />
    }
}
```
Otherwise you have to use the `Bundle.load` promise and follow the `getComponent` 
callback API and use the HOC when the class is loaded.

### Q. what is the syntax to set an event handler?

```haxe
<Route path="/" component=${Home} onEnter=${enterHandler} />

function enterHandler(nextState:RouterState, replace:String->Void, completed:Void->Void)
```
