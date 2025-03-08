

import 'package:biphip_messenger/models/common/common_link_model.dart';
import 'package:biphip_messenger/models/common/common_user_model.dart';

class MessageListModel {
    Messages? messages;

    MessageListModel({
        this.messages,
    });

    factory MessageListModel.fromJson(Map<String, dynamic> json) => MessageListModel(
        messages: json["messages"] == null ? null : Messages.fromJson(json["messages"]),
    );
}

class Messages {
    int? currentPage;
    List<MessageData>? data;
    String? firstPageUrl;
    int? from;
    int? lastPage;
    String? lastPageUrl;
    List<CommonLink>? links;
    dynamic nextPageUrl;
    String? path;
    int? perPage;
    dynamic prevPageUrl;
    int? to;
    int? total;

    Messages({
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

    factory Messages.fromJson(Map<String, dynamic> json) => Messages(
        currentPage: json["current_page"],
        data: json["data"] == null ? [] : List<MessageData>.from(json["data"]!.map((x) => MessageData.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: json["links"] == null ? [] : List<CommonLink>.from(json["links"]!.map((x) => CommonLink.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
    );
}

class MessageData {
    int? id;
    int? type;
    int? senderId;
    int? mRoomId;
    String? text;
    dynamic audios;
    dynamic images;
    dynamic videos;
    dynamic files;
    dynamic seenBy;
    int? removeForSender;
    int? removeForAll;
    String? deletedBy;
    DateTime? createdAt;
    DateTime? updatedAt;
    String? messageText;
    bool? isSentByMe;
    bool? isPinnedByMe;
    String? senderName;
    String? senderImage;
    List<dynamic>? imageUrls;
    List<dynamic>? videoUrls;
    List<dynamic>? fileUrls;
    Reactions? reactions;
    List<dynamic>? reactors;
    User? sender;
    MRoom? mRoom;

    MessageData({
        this.id,
        this.type,
        this.senderId,
        this.mRoomId,
        this.text,
        this.audios,
        this.images,
        this.videos,
        this.files,
        this.seenBy,
        this.removeForSender,
        this.removeForAll,
        this.deletedBy,
        this.createdAt,
        this.updatedAt,
        this.messageText,
        this.isSentByMe,
        this.isPinnedByMe,
        this.senderName,
        this.senderImage,
        this.imageUrls,
        this.videoUrls,
        this.fileUrls,
        this.reactions,
        this.reactors,
        this.sender,
        this.mRoom,
    });

    factory MessageData.fromJson(Map<String, dynamic> json) => MessageData(
        id: json["id"],
        type: json["type"],
        senderId: json["sender_id"],
        mRoomId: json["m_room_id"],
        text: json["text"],
        audios: json["audios"],
        images: json["images"],
        videos: json["videos"],
        files: json["files"],
        seenBy: json["seen_by"],
        removeForSender: json["remove_for_sender"],
        removeForAll: json["remove_for_all"],
        deletedBy: json["deleted_by"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        messageText: json["message_text"],
        isSentByMe: json["is_sent_by_me"],
        isPinnedByMe: json["is_pinned_by_me"],
        senderName: json["sender_name"],
        senderImage: json["sender_image"],
        imageUrls: json["image_urls"] == null ? [] : List<dynamic>.from(json["image_urls"]!.map((x) => x)),
        videoUrls: json["video_urls"] == null ? [] : List<dynamic>.from(json["video_urls"]!.map((x) => x)),
        fileUrls: json["file_urls"] == null ? [] : List<dynamic>.from(json["file_urls"]!.map((x) => x)),
        reactions: json["reactions"] == null ? null : Reactions.fromJson(json["reactions"]),
        reactors: json["reactors"] == null ? [] : List<dynamic>.from(json["reactors"]!.map((x) => x)),
        sender: json["sender"] == null ? null : User.fromJson(json["sender"]),
        mRoom: json["m_room"] == null ? null : MRoom.fromJson(json["m_room"]),
    );
}

class MRoom {
    int? id;
    dynamic name;
    dynamic image;
    int? status;
    int? type;
    dynamic creatorId;
    dynamic kidId;
    dynamic storeId;
    int? lastMessageId;
    int? lastMessageSenderId;
    DateTime? createdAt;
    DateTime? updatedAt;
    String? roomName;
    List<String>? roomImage;
    int? roomUserId;

    MRoom({
        this.id,
        this.name,
        this.image,
        this.status,
        this.type,
        this.creatorId,
        this.kidId,
        this.storeId,
        this.lastMessageId,
        this.lastMessageSenderId,
        this.createdAt,
        this.updatedAt,
        this.roomName,
        this.roomImage,
        this.roomUserId,
    });

    factory MRoom.fromJson(Map<String, dynamic> json) => MRoom(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        status: json["status"],
        type: json["type"],
        creatorId: json["creator_id"],
        kidId: json["kid_id"],
        storeId: json["store_id"],
        lastMessageId: json["last_message_id"],
        lastMessageSenderId: json["last_message_sender_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        roomName: json["room_name"],
        roomImage: json["room_image"] == null
            ? []
            : List<String>.from(
            json["room_image"].where((x) => x != null && x is String)
        ),
        roomUserId: json["room_user_id"],

    );

}

class Reactions {
    int? total;

    Reactions({
        this.total,
    });

    factory Reactions.fromJson(Map<String, dynamic> json) => Reactions(
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
    };
}