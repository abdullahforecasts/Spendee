// lib/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePic;
  final String uuid;
  final bool verified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
    required this.uuid,
    required this.verified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePic: json['profilePic'],
      uuid: json['uuid'] ?? '',
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'uuid': uuid,
      'verified': verified,
    };
  }
}

// lib/models/room_model.dart
class RoomModel {
  final String id;
  final String name;
  final String description;
  final UserModel createdBy;
  final List<UserModel> members;
  final String color;
  final String icon;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.members,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdBy: UserModel.fromJson(json['createdBy']),
      members: (json['members'] as List?)
              ?.map((m) => UserModel.fromJson(m))
              .toList() ??
          [],
      color: json['color'] ?? '#3B82F6',
      icon: json['icon'] ?? '👥',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// lib/models/group_member_model.dart
class GroupMemberModel {
  final UserModel user;
  final double shareAmount;
  final double amountPaid;
  final bool hasPaid;
  final DateTime? lastPaymentDate;

  GroupMemberModel({
    required this.user,
    required this.shareAmount,
    required this.amountPaid,
    required this.hasPaid,
    this.lastPaymentDate,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      user: UserModel.fromJson(json['user']),
      shareAmount: (json['shareAmount'] ?? 0).toDouble(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      hasPaid: json['hasPaid'] ?? false,
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.parse(json['lastPaymentDate'])
          : null,
    );
  }
}

// lib/models/payment_method_model.dart
class PaymentMethodModel {
  final String type;
  final String? accountTitle;
  final String? accountNumber;
  final String? iban;
  final String? bankName;
  final String? deepLink;
  final bool isActive;

  PaymentMethodModel({
    required this.type,
    this.accountTitle,
    this.accountNumber,
    this.iban,
    this.bankName,
    this.deepLink,
    required this.isActive,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      type: json['type'] ?? '',
      accountTitle: json['accountTitle'],
      accountNumber: json['accountNumber'],
      iban: json['iban'],
      bankName: json['bankName'],
      deepLink: json['deepLink'],
      isActive: json['isActive'] ?? true,
    );
  }
}

// lib/models/group_model.dart
class GroupModel {
  final String id;
  final String name;
  final String description;
  final UserModel leader;
  final List<GroupMemberModel> members;
  final double goalAmount;
  final double currentAmount;
  final String splitMethod;
  final List<PaymentMethodModel> paymentMethods;
  final DateTime? deadline;
  final String status;
  final String? coverImage;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.leader,
    required this.members,
    required this.goalAmount,
    required this.currentAmount,
    required this.splitMethod,
    required this.paymentMethods,
    this.deadline,
    required this.status,
    this.coverImage,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      leader: UserModel.fromJson(json['leader']),
      members: (json['members'] as List?)
              ?.map((m) => GroupMemberModel.fromJson(m))
              .toList() ??
          [],
      goalAmount: (json['goalAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      splitMethod: json['splitMethod'] ?? 'equal',
      paymentMethods: (json['paymentMethods'] as List?)
              ?.map((p) => PaymentMethodModel.fromJson(p))
              .toList() ??
          [],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      status: json['status'] ?? 'draft',
      coverImage: json['coverImage'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  double get progressPercentage => goalAmount > 0 ? currentAmount / goalAmount : 0.0;

  int get paidCount => members.where((m) => m.hasPaid).length;
  int get totalCount => members.length;
}