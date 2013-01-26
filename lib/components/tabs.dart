import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:bot/bot.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

// TODO:TEST: no active tabs -> first is active
// TODO:TEST: 2+ active tabs -> all but first is active
// TODO:TEST: no tabs -> no crash

// TODO: be more careful that the source tab is actually 'ours'
// TODO: support click on child elements with data-toggle="tab"

class Tabs extends WebComponent {
  @protected
  void created() {
    this.on.click.add(_clickListener);
  }

  @protected
  void inserted() {
    _ensureAtMostOneTabActive();
  }

  void _clickListener(MouseEvent e) {
    if(!e.defaultPrevented && e.target is Element) {
      final Element target = e.target;
      final completed = _targetClick(target);
      if(completed) {
        e.preventDefault();
      }
    }
  }

  bool _targetClick(Element clickElement) {
    final toggleData = clickElement.dataAttributes['toggle'];
    if(toggleData != 'tab' && toggleData != 'pill') {
      return false;
    }

    //
    // The parent tab to the click should become active
    //
    final allTabs = _getAllTabs();
    final clickAncestors = Tools.getAncestors(clickElement);
    final activatedTab = allTabs.firstMatching((t) => clickAncestors.contains(t), orElse: () => null);
    if(activatedTab != null) {
      allTabs.forEach((t) {
        if(t == activatedTab) {
          t.classes.add('active');
        } else {
          t.classes.remove('active');
        }
      });
    }

    //
    // Find the target for the click
    //
    final target = _getClickTarget(clickElement);

    //
    // Try to find and activate the content for the target
    //
    if(target != null) {
      _updateContent(target);
    }

    return true;
  }

  static String _getClickTarget(Element clickedElement) {
    assert(clickedElement != null);
    String target = clickedElement.dataAttributes['target'];
    if(target == null) {
      final href = clickedElement.attributes['href'];
      if(href != null && href.startsWith('#')) {
        target = href.substring(1);
      }
    }
    return target;
  }

  List<Element> _getAllTabs() => this.queryAll('x-tabs > .nav-tabs > li');

  void _ensureAtMostOneTabActive() {
    final tabs = _getAllTabs();
    Element activeTab = null;
    tabs.forEach((Element tab) {
      if(tab.classes.contains('active')) {
        if(activeTab == null) {
          activeTab = tab;
        } else {
          tab.classes.remove('active');
        }
      }
    });

    if(activeTab == null && !tabs.isEmpty) {
      activeTab = tabs[0];
      activeTab.classes.add('active');
    }
  }

  SwapComponent _getSwap() {
    final Element element = this.query('x-tabs > x-swap');
    if(element != null) {
      if(element is SwapComponent) {
        return element;
      } else if(element.xtag is SwapComponent) {
        return element.xtag;
      }
    }
    return null;
  }

  void _updateContent(String target) {
    final swap = _getSwap();

    if(swap != null) {
      final items = swap.items;

      final targetItem = $(items).firstMatching((e) => e.id == target, orElse: () => null);
      if(targetItem != null) {
        swap.showItem(targetItem);
      }
    }
  }
}
