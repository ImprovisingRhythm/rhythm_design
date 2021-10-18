import 'package:flutter/widgets.dart';

import 'bottom_navigation.dart';
import 'scaffold.dart';
import 'tab_view.dart';

class BottomNavigationScaffold extends StatefulWidget {
  const BottomNavigationScaffold({
    Key? key,
    required this.tabPages,
    required this.bottomNavigationItems,
    this.initialIndex = 0,
  })  : assert(tabPages.length == bottomNavigationItems.length),
        super(key: key);

  final List<Widget> tabPages;
  final List<BottomNavigationItem> bottomNavigationItems;
  final int initialIndex;

  @override
  _BottomNavigationScaffoldState createState() =>
      _BottomNavigationScaffoldState();
}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: widget.tabPages.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigation: BottomNavigation(
        label: true,
        items: widget.bottomNavigationItems,
        index: _tabController.index,
        onChange: (index) {
          if (!mounted) return;

          setState(() {
            _tabController.animateTo(index);
          });
        },
      ),
      body: TabView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: widget.tabPages,
      ),
    );
  }
}
