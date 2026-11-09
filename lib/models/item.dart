import 'storable.dart';

abstract class Item implements Storable {
  String id;
  String name;

  Item(this.id, this.name);

  String describe();
}