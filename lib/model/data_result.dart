class DataResult {
  var data;
  bool result;
  String description;
  Function next;

  DataResult(this.data, this.result, {this.description,this.next});

  @override
  String toString() {
    return 'DataResult{data: $data, result: $result, description: $description, next: $next}';
  }
}