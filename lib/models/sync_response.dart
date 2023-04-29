class SyncResponse {
  final bool isAutoSync;
  final String name;
  final bool isFinished;
  final String message;
  final String error;
  final double progress;

  const SyncResponse({
    required this.isAutoSync,
    required this.name,
    required this.isFinished,
    required this.message,
    required this.error,
    required this.progress,
  });

  Map<String, dynamic> toJson() {
    return {
      'isAutoSync': isAutoSync,
      'name': name,
      'isFinished': isFinished,
      'message': message,
      'error': error,
      'progress': progress,
    };
  }

  factory SyncResponse.fromJson(Map<String, dynamic> map) {
    return SyncResponse(
      isAutoSync: map['isAutoSync'] as bool,
      name: map['name'] as String,
      isFinished: map['isFinished'] as bool,
      message: map['message'] as String,
      error: map['error'] as String,
      progress: map['progress'] as double,
    );
  }
}