class AutoCompleteResult {
  final String description;
  final String placeId;

  AutoCompleteResult({
    required this.description,
    required this.placeId,
  });

  factory AutoCompleteResult.fromJson(Map<String, dynamic> json) {
    return AutoCompleteResult(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
    );
  }
}
