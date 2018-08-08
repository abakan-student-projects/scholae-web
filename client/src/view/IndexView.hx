package view;

import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;

class IndexView extends ReactComponent {

    public function new()
    {
        super();
    }

    override function render() {
        return
            jsx('
                <p>
                Scholae поможет изучить алгоритмы и программирование на задачах <a href="http://codeforces.ru">Codeforces</a>.
                </p>
            ');
    }
}
