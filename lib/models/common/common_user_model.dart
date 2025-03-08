class User {
    int? id;
    String? image;
    String? userName;
    String? referralCode;
    String? firstName;
    String? lastName;
    String? email;
    dynamic phone;
    String? gender;
    DateTime? dob;
    List<dynamic> profession;
    List<String> interest;
    String? bio;
    List<String> languages;
    String? status;
    dynamic blockTill;
    dynamic otp;
    dynamic refId;
    String? relation;
    String? relationWithName;
    int? relationWithId;
    DateTime? relationSince;
    String? cover;
    dynamic badge;
    dynamic socialProvider;
    String? referralUrl;
    String? fullName;
    String? profilePicture;
    String? coverPhoto;
    String? currentBadge;
    int? friendStatus;
    int? followStatus;
    dynamic familyRelationStatus;
    int? mutualFriend;
    UserPendent? userPendent;
    int? starBalance;

    User({
        required this.id,
        required this.image,
        required this.userName,
        required this.referralCode,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.phone,
        required this.gender,
        required this.dob,
        required this.profession,
        required this.interest,
        required this.bio,
        required this.languages,
        required this.status,
        required this.blockTill,
        required this.otp,
        required this.refId,
        required this.relation,
        required this.relationWithName,
        required this.relationWithId,
        required this.relationSince,
        required this.cover,
        required this.badge,
        required this.socialProvider,
        required this.referralUrl,
        required this.fullName,
        required this.profilePicture,
        required this.coverPhoto,
        required this.currentBadge,
        required this.friendStatus,
        required this.followStatus,
        required this.familyRelationStatus,
        required this.mutualFriend,
        this.userPendent,
        this.starBalance,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        image: json["image"],
        userName: json["user_name"],
        referralCode: json["referral_code"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        phone: json["phone"],
        gender: json["gender"],
        dob: DateTime.parse(json["dob"]),
        profession: List<dynamic>.from(json["profession"].map((x) => x)),
        interest: List<String>.from(json["interest"].map((x) => x)),
        bio: json["bio"],
        languages: List<String>.from(json["languages"].map((x) => x)),
        status: json["status"],
        blockTill: json["block_till"],
        otp: json["otp"],
        refId: json["ref_id"],
        relation: json["relation"],
        relationWithName: json["relation_with_name"],
        relationWithId: json["relation_with_id"],
        relationSince: json["relation_since"]==null? null:DateTime.parse(json["relation_since"]),
        cover: json["cover"],
        badge: json["badge"],
        socialProvider: json["social_provider"],
        referralUrl: json["referral_url"],
        fullName: json["full_name"],
        profilePicture: json["profile_picture"],
        coverPhoto: json["cover_photo"],
        currentBadge: json["current_badge"],
        friendStatus: json["friend_status"],
        followStatus: json["follow_status"],
        familyRelationStatus: json["family_relation_status"],
        mutualFriend: json["mutual_friend"],
        userPendent: json["pendent"] == null ? null : UserPendent.fromJson(json["pendent"]),
        starBalance: json["star_balance"],
    );
}

class UserPendent {
    int? id;
    int? pendentId;
    int? userId;
    DateTime? startDate;
    DateTime? endDate;
    int? isActive;
    String? pendentPurchaseHistory;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? affiliateDistribute;
    Pendent? pendent;

    UserPendent({
        this.id,
        this.pendentId,
        this.userId,
        this.startDate,
        this.endDate,
        this.isActive,
        this.pendentPurchaseHistory,
        this.createdAt,
        this.updatedAt,
        this.affiliateDistribute,
        this.pendent,
    });

    factory UserPendent.fromJson(Map<String, dynamic> json) => UserPendent(
        id: json["id"],
        pendentId: json["pendent_id"],
        userId: json["user_id"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        isActive: json["is_active"],
        pendentPurchaseHistory: json["pendent_purchase_history"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        affiliateDistribute: json["affiliate_distribute"],
        pendent: json["pendent"] == null ? null : Pendent.fromJson(json["pendent"]),
    );
}


class Pendent {
    int? id;
    String? name;
    String? description;
    String? icon;
    int? price;
    int? star;
    int? validityDays;
    int? monthlyRoi;
    int? dailyRoi;
    int? affilate;
    int? giftSendBenefits;
    int? giftReceiveBenefits;
    int? isActive;
    dynamic createdAt;
    dynamic updatedAt;

    Pendent({
        this.id,
        this.name,
        this.description,
        this.icon,
        this.price,
        this.star,
        this.validityDays,
        this.monthlyRoi,
        this.dailyRoi,
        this.affilate,
        this.giftSendBenefits,
        this.giftReceiveBenefits,
        this.isActive,
        this.createdAt,
        this.updatedAt,
    });

    factory Pendent.fromJson(Map<String, dynamic> json) => Pendent(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        icon: json["icon"],
        price: json["price"],
        star: json["star"],
        validityDays: json["validity_days"],
        monthlyRoi: json["monthly_roi"],
        dailyRoi: json["daily_roi"],
        affilate: json["affilate"],
        giftSendBenefits: json["gift_send_benefits"],
        giftReceiveBenefits: json["gift_receive_benefits"],
        isActive: json["is_active"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );
}