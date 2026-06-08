class Employee {
  final int id;
  final String employeeName;
  final int employeePhone;
  final String designation;
  final DateTime createdAt;
  final String role;

  Employee({
    required this.id,
    required this.employeeName,
    required this.employeePhone,
    required this.designation,
    required this.createdAt,
    required this.role,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeName: json['EmployeeName'] ?? '',
      employeePhone: json['EmployeePhone'] ?? 0,
      designation: json['designation'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      role: json['role'] ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'EmployeeName': employeeName,
      'EmployeePhone': employeePhone,
      'designation': designation,
      'created_at': createdAt.toIso8601String(),
      'role': role,
    };
  }
}

class Workshop {
  final int id;
  final String workshopPlace;
  final DateTime workshopTime;
  final String workshopLocation;
  final DateTime createdAt;

  Workshop({
    required this.id,
    required this.workshopPlace,
    required this.workshopTime,
    required this.workshopLocation,
    required this.createdAt,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'],
      workshopPlace: json['workshop_place'] ?? '',
      workshopTime: json['workshop_time'] != null ? DateTime.parse(json['workshop_time']) : DateTime.now(),
      workshopLocation: json['workshop_location'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop_place': workshopPlace,
      'workshop_time': workshopTime.toIso8601String(),
      'workshop_location': workshopLocation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Attendance {
  final int id;
  final String workshopName;
  final String locationStatus;
  final String attendance;
  final DateTime createdAt;
  final String? imageUrl;

  Attendance({
    required this.id,
    required this.workshopName,
    required this.locationStatus,
    required this.attendance,
    required this.createdAt,
    this.imageUrl,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      workshopName: json['workshop_name'] ?? '',
      locationStatus: json['location_status'] ?? '',
      attendance: json['attendance'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop_name': workshopName,
      'location_status': locationStatus,
      'attendance': attendance,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}

class Leave {
  final int id;
  final String employeeName;
  final String leaveTitle;
  final String leaveDescription;
  final String leaveStatus;
  final DateTime createdAt;

  Leave({
    required this.id,
    required this.employeeName,
    required this.leaveTitle,
    required this.leaveDescription,
    required this.leaveStatus,
    required this.createdAt,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      employeeName: json['employeeName'] ?? '',
      leaveTitle: json['leave_title'] ?? '',
      leaveDescription: json['leave_decription'] ?? '', // matching db typo
      leaveStatus: json['leave_status'] ?? 'Pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'leave_title': leaveTitle,
      'leave_decription': leaveDescription,
      'leave_status': leaveStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Inventory {
  final int id;
  final String itemName;
  final String sku;
  final String category;
  final int stock;
  final String status;
  final DateTime createdAt;

  Inventory({
    required this.id,
    required this.itemName,
    required this.sku,
    required this.category,
    required this.stock,
    required this.status,
    required this.createdAt,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      itemName: json['item_name'] ?? '',
      sku: json['sku'] ?? '',
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'sku': sku,
      'category': category,
      'stock': stock,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Message {
  final String id;
  final int senderId;
  final int? receiverId;
  final bool isGroup;
  final String content;
  final DateTime createdAt;
  final Employee? sender;

  Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.isGroup,
    required this.content,
    required this.createdAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'],
      isGroup: json['is_group'] ?? false,
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      sender: json['employees'] != null ? Employee.fromJson(json['employees']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'is_group': isGroup,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
