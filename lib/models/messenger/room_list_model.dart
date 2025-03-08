import 'package:biphip_messenger/models/common/common_link_model.dart';
import 'package:biphip_messenger/models/common/common_user_model.dart';

class RoomListModel {
  Rooms? rooms;

  RoomListModel({
    this.rooms,
  });

  factory RoomListModel.fromJson(Map<String, dynamic> json) => RoomListModel(
        rooms: json["rooms"] == null ? null : Rooms.fromJson(json["rooms"]),
      );
}

class Rooms {
  int? currentPage;
  List<RoomData>? data;
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

  Rooms({
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

  factory Rooms.fromJson(Map<String, dynamic> json) => Rooms(
        currentPage: json["current_page"],
        data: json["data"] == null ? [] : List<RoomData>.from(json["data"]!.map((x) => RoomData.fromJson(x))),
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

class RoomData {
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
  DateTime? updatedAt;
  String? roomName;
  List<String>? roomImage;
  int? roomUserId;
  List<Participant>? participants;
  int? isDelivered;
  int? isSeen;
  int? isMute;
  LastMessage? lastMessage;

  RoomData(
      {this.id,
      this.name,
      this.image,
      this.status,
      this.type,
      this.creatorId,
      this.kidId,
      this.storeId,
      this.lastMessageId,
      this.lastMessageSenderId,
      this.roomName,
      this.roomImage,
      this.roomUserId,
      this.participants,
      this.updatedAt,
      this.isDelivered,
      this.isMute,
      this.isSeen,
      this.lastMessage});

  factory RoomData.fromJson(Map<String, dynamic> json) => RoomData(
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
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        roomName: json["room_name"],
        roomImage: json["room_image"] == null ? [] : List<String>.from(json["room_image"].where((x) => x != null && x is String)),
        roomUserId: json["room_user_id"],
        participants: json["participants"] == null ? [] : List<Participant>.from(json["participants"]!.map((x) => Participant.fromJson(x))),
        isDelivered: json["is_delivered"],
        isMute: json["is_mute"],
        isSeen: json["is_seen"],
        lastMessage: json["last_message"] == null ? null : LastMessage.fromJson(json["last_message"]),
      );
}

class Participant {
  int? id;
  int? mRoomId;
  int? userId;
  String? userNickname;
  dynamic deletedMessageId;
  int? isDeleted;
  int? isArchived;
  dynamic archivedAt;

  Participant({
    this.id,
    this.mRoomId,
    this.userId,
    this.userNickname,
    this.deletedMessageId,
    this.isDeleted,
    this.isArchived,
    this.archivedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        mRoomId: json["m_room_id"],
        userId: json["user_id"],
        userNickname: json["user_nickname"],
        deletedMessageId: json["deleted_message_id"],
        isDeleted: json["is_deleted"],
        isArchived: json["is_archived"],
        archivedAt: json["archived_at"],
      );
}

class LastMessage {
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
  List<dynamic> imageUrls;
  List<dynamic> videoUrls;
  List<dynamic> fileUrls;
  Reactions? reactions;
  List<dynamic> reactors;
  User? sender;
  MRoom? mRoom;

  LastMessage({
    required this.id,
    required this.type,
    required this.senderId,
    required this.mRoomId,
    required this.text,
    required this.audios,
    required this.images,
    required this.videos,
    required this.files,
    required this.seenBy,
    required this.removeForSender,
    required this.removeForAll,
    required this.deletedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.messageText,
    required this.isSentByMe,
    required this.isPinnedByMe,
    required this.senderName,
    required this.senderImage,
    required this.imageUrls,
    required this.videoUrls,
    required this.fileUrls,
    required this.reactions,
    required this.reactors,
    required this.sender,
    required this.mRoom,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
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
        imageUrls: List<dynamic>.from(json["image_urls"].map((x) => x)),
        videoUrls: List<dynamic>.from(json["video_urls"].map((x) => x)),
        fileUrls: List<dynamic>.from(json["file_urls"].map((x) => x)),
        reactions: Reactions.fromJson(json["reactions"]),
        reactors: List<dynamic>.from(json["reactors"].map((x) => x)),
        sender: User.fromJson(json["sender"]),
        mRoom: MRoom.fromJson(json["m_room"]),
      );
}

class MRoom {
  int id;
  dynamic name;
  dynamic image;
  int status;
  int type;
  dynamic creatorId;
  dynamic kidId;
  dynamic storeId;
  int lastMessageId;
  int lastMessageSenderId;
  DateTime createdAt;
  DateTime updatedAt;
  String roomName;
  List<String> roomImage;
  int roomUserId;
  int isDelivered;
  int isSeen;
  int isMute;

  MRoom({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.type,
    required this.creatorId,
    required this.kidId,
    required this.storeId,
    required this.lastMessageId,
    required this.lastMessageSenderId,
    required this.createdAt,
    required this.updatedAt,
    required this.roomName,
    required this.roomImage,
    required this.roomUserId,
    required this.isDelivered,
    required this.isSeen,
    required this.isMute,
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
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        roomName: json["room_name"],
        roomImage: List<String>.from(json["room_image"].map((x) => x)),
        roomUserId: json["room_user_id"],
        isDelivered: json["is_delivered"],
        isSeen: json["is_seen"],
        isMute: json["is_mute"],
      );
}

class Reactions {
  int total;

  Reactions({
    required this.total,
  });

  factory Reactions.fromJson(Map<String, dynamic> json) => Reactions(
        total: json["total"],
      );
}
