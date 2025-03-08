class CommonDM {
  final bool success;
  final String message;
  final int? code;

  final dynamic _data;

  CommonDM(this.success, this.message, this.code, this._data);

  CommonDM.fromJson(Map<String, dynamic> json)
      :
        success = json['success'],
        // success = true,
        message = json['message'] ?? "",
        code = json['code'] ?? 200,
        _data = json['data'];

  dynamic get data => _data;

  @override
  String toString() {
    return 'CommonDM{success: $success, message: $message, code: $code, _customRequest: $_data}';
  }
}
