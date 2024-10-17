import 'package:demoapp/constants/change_type.dart';
import 'package:flutter/material.dart';

//entry point for App
void main() {
  runApp(const DockWidget());
}

/// A widget that provides a dock with customizable items,
/// allowing the user to reorder them horizontally.
class DockWidget extends StatelessWidget {
  const DockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                key: ValueKey(icon),
                constraints: const BoxConstraints(
                  minWidth: 55,
                  maxWidth: 55,
                ),
                height: 48,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A customizable and reorderable dock widget that takes a list of items
/// and renders them horizontally.
///
/// [T] - The type of the items in the dock.
class Dock<T> extends StatefulWidget {
  /// Creates a dock widget with the given [items] and a builder function [builder].
  ///
  /// The [items] parameter defines the list of items to display in the dock.
  /// The [builder] parameter provides a way to customize how each item is rendered.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// The list of items to display in the dock.
  final List<T> items;

  /// A builder function to customize how each item is rendered.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  /// A copy of the items passed to the dock for local state management.
  late final List<T> _items = widget.items.toList();

  ///defines the width of dock for initial items
  late double widthOfDock;

  @override
  void initState() {
    ///individual width of item including margin times number of items
    widthOfDock = 75 * double.parse(_items.length.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 75,
      width: widthOfDock,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ReorderableListView.builder(
        onReorderStart: (index) {
          ///trigger change of width for the dock when drag start
          calculateWidthOfDock(ChangeType.decrease);
        },
        onReorderEnd: (index) {
          ///trigger change of width for the dock when drag end
          calculateWidthOfDock(ChangeType.increase);
        },
        buildDefaultDragHandles: false, //set to false to remove menu icon from each items
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        onReorder: _onReorder,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ReorderableDragStartListener(
            key: ValueKey(item),
            index: index,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: widget.builder(item),
            ),
          );
        },
      ),
    );
  }

  ///Calculate new width of the dock based on the number of items
  ///Takes [ChangeType] to determine whether it is increase or decrease
  void calculateWidthOfDock(ChangeType type) {
    if (type == ChangeType.increase) {
      setState(() {
        widthOfDock = widthOfDock + 75;
      });
    } else {
      setState(() {
        widthOfDock = widthOfDock - 75;
      });
    }
  }

  /// Handles the reordering of items when the user drags an item to a new position.
  ///
  /// The [oldIndex] parameter is the original index of the item being moved.
  /// The [newIndex] parameter is the new index where the item should be placed.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }
}
