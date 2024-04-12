class DeviceCommandModel {
  String? deviceId;
  String? type;
  Content? content;

  DeviceCommandModel({this.deviceId, this.type, this.content});

  DeviceCommandModel.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    type = json['type'];
    content =
        json['content'] != null ? Content.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['type'] = type;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class Content {
  int? switchNo;
  String? status;

  Content({this.switchNo, this.status});

  Content.fromJson(Map<String, dynamic> json) {
    switchNo = json['switchNo'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['switchNo'] = switchNo;
    data['status'] = status;
    return data;
  }
}
