package view;

import react.ReactComponent;
import react.ReactMacro.jsx;

typedef PaginatorProps = {
    pagesCount: Int,
    activePage: Int,
    onChange: Int -> Void
}

class PaginatorView extends ReactComponentOfProps<PaginatorProps> {

    public function new()
    {
        super();
    }

    override function render() {
        var items = [];
        for (i in 1...props.pagesCount) {
            items.push(
                if (i != props.activePage)
                    jsx('<li key=$i><a href="#" onClick=${props.onChange.bind(i)}>$i</a></li>')
                else
                    jsx('<li key=$i className="uk-active"><span>$i</span></li>'));
        }

        var prev = if (props.activePage > 1) jsx('<li><a href="#" onClick=${props.onChange.bind(props.activePage-1)}><span data-uk-pagination-previous=""></span></a></li>') else null;
        var next = if (props.activePage < props.pagesCount) jsx('<li><a href="#" onClick=${props.onChange.bind(props.activePage+1)}><span data-uk-pagination-next=""></span></a></li>') else null;

        return jsx('
            <ul className="uk-pagination" data-uk-margin=${true}>
                $prev
                $items
                $next
            </ul>
        ');
    }
}
