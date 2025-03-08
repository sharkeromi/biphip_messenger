class ErrorModel {
  List<Error> errors;

  ErrorModel({
    required this.errors,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
        errors: List<Error>.from(json["errors"].map((x) => Error.fromJson(x))),
      );
}

class Error {
  String fieldName;
  String message;

  Error({
    required this.fieldName,
    required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        fieldName: json["field_name"],
        message: json["message"],
      );
}
