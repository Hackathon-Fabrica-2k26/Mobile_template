class Item {
  final int? id;
  final String title;
  final String description;
  final bool done;
  final int? owner;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Item({
    this.id,
    required this.title,
    this.description = '',
    this.done = false,
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      done: json['done'] as bool? ??
          (json['status'] == 'completed' || json['status'] == 'done'),
      owner: json['owner'] is int
          ? json['owner'] as int
          : (json['owner'] != null ? int.tryParse(json['owner'].toString()) : null),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'done': done,
    };
  }

  Item copyWith({
    int? id,
    String? title,
    String? description,
    bool? done,
    int? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
