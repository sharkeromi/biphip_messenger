import 'package:biphip_messenger/models/common/common_link_model.dart';
import 'package:biphip_messenger/models/common/common_user_model.dart';

class UserListModel {
    Users? users;

    UserListModel({
         this.users,
    });

    factory UserListModel.fromJson(Map<String, dynamic> json) => UserListModel(
        users: Users.fromJson(json["users"]),
    );
}

class Users {
    int? currentPage;
    List<User>? data;
    String? firstPageUrl;
    int? from;
    int? lastPage;
    String? lastPageUrl;
    List<CommonLink>? links;
    String? nextPageUrl;
    String? path;
    int? perPage;
    dynamic prevPageUrl;
    int? to;
    int? total;

    Users({
         this.currentPage,
         this.data,
         this.firstPageUrl,
         this.from,
         this.lastPage,
         this.lastPageUrl,
         this.links,
         this.nextPageUrl,
         this.path,
         this.perPage,
         this.prevPageUrl,
         this.to,
         this.total,
    });

    factory Users.fromJson(Map<String, dynamic> json) => Users(
        currentPage: json["current_page"],
        data: List<User>.from(json["data"].map((x) => User.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: List<CommonLink>.from(json["links"].map((x) => CommonLink.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
    );
}

