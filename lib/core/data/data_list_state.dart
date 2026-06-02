class DataListState<T> {
  List<T> all = [];
  List<T> filtered = [];

  void setItems(List<T> items) {
    all = items;
    filtered = List<T>.from(items);
  }

  void resetFilter() {
    filtered = List<T>.from(all);
  }

  void filter(bool Function(T item) predicate) {
    filtered = all.where(predicate).toList();
  }
}
