class CommonLink {
  String? url;
  String? label;
  bool? active;

  CommonLink({
    required this.url,
    required this.label,
    required this.active,
  });

  factory CommonLink.fromJson(Map<String, dynamic> json) => CommonLink(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );
}