class NetworkInventoryValidationException implements Exception {
  final String message;

  const NetworkInventoryValidationException(this.message);

  @override
  String toString() => 'NetworkInventoryValidationException: $message';
}

class NetworkInventory {
  NetworkInventory();

  factory NetworkInventory.empty() => NetworkInventory();

  bool get isEmpty => true;

  Map<String, dynamic> toJson() => {
        'network-inventory': {
          'network-elements': {
            'network-element': <Map<String, dynamic>>[],
          },
        },
      };

  factory NetworkInventory.fromJson(Map<String, dynamic> json) =>
      NetworkInventory.empty();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NetworkInventory;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'NetworkInventory()';
}

class NetworkElement {
  final String neId;
  final String? neType;
  final String? uuid;
  final String? name;
  final String? alias;
  final String? description;
  final String? mfgName;
  final String? productName;
  final String? productRev;

  NetworkElement({
    required this.neId,
    this.neType,
    this.uuid,
    this.name,
    this.alias,
    this.description,
    this.mfgName,
    this.productName,
    this.productRev,
  }) {
    if (neId.trim().isEmpty) {
      throw const NetworkInventoryValidationException('neId must not be empty');
    }
  }

  bool isValid() => neId.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'ne-id': neId,
        if (neType != null) 'ne-type': neType,
        if (uuid != null) 'uuid': uuid,
        if (name != null) 'name': name,
        if (alias != null) 'alias': alias,
        if (description != null) 'description': description,
        if (mfgName != null) 'mfg-name': mfgName,
        if (productName != null) 'product-name': productName,
        if (productRev != null) 'product-rev': productRev,
      };

  factory NetworkElement.fromJson(Map<String, dynamic> json) {
    return NetworkElement(
      neId: json['ne-id'] as String,
      neType: json['ne-type'] as String?,
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      alias: json['alias'] as String?,
      description: json['description'] as String?,
      mfgName: json['mfg-name'] as String?,
      productName: json['product-name'] as String?,
      productRev: json['product-rev'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkElement &&
          other.neId == neId &&
          other.neType == neType &&
          other.uuid == uuid &&
          other.name == name &&
          other.alias == alias &&
          other.description == description &&
          other.mfgName == mfgName &&
          other.productName == productName &&
          other.productRev == productRev;

  @override
  int get hashCode => Object.hash(
        neId,
        neType,
        uuid,
        name,
        alias,
        description,
        mfgName,
        productName,
        productRev,
      );

  @override
  String toString() => 'NetworkElement(neId: $neId, name: $name)';
}

class Component {
  final String componentId;
  final String? class_;
  final String? mfgName;
  final String? productName;
  final String? hardwareRev;
  final String? partNumber;
  final String? serialNumber;
  final bool? isFru;
  final List<String> parent;
  final String? parentRelPos;
  final bool? isMain;

  Component({
    required this.componentId,
    this.class_,
    this.mfgName,
    this.productName,
    this.hardwareRev,
    this.partNumber,
    this.serialNumber,
    this.isFru,
    this.parent = const [],
    this.parentRelPos,
    this.isMain,
  }) {
    if (componentId.trim().isEmpty) {
      throw const NetworkInventoryValidationException(
        'componentId must not be empty',
      );
    }
  }

  bool isValid() => componentId.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'component-id': componentId,
        if (class_ != null) 'class': class_,
        if (mfgName != null) 'mfg-name': mfgName,
        if (productName != null) 'product-name': productName,
        if (hardwareRev != null) 'hardware-rev': hardwareRev,
        if (partNumber != null) 'part-number': partNumber,
        if (serialNumber != null) 'serial-number': serialNumber,
        if (isFru != null) 'is-fru': isFru,
        if (parent.isNotEmpty) 'parent': parent,
        if (parentRelPos != null) 'parent-rel-pos': parentRelPos,
        if (isMain != null) 'is-main': isMain,
      };

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      componentId: json['component-id'] as String,
      class_: json['class'] as String?,
      mfgName: json['mfg-name'] as String?,
      productName: json['product-name'] as String?,
      hardwareRev: json['hardware-rev'] as String?,
      partNumber: json['part-number'] as String?,
      serialNumber: json['serial-number'] as String?,
      isFru: json['is-fru'] as bool?,
      parent: (json['parent'] as List<dynamic>?)?.cast<String>() ?? [],
      parentRelPos: json['parent-rel-pos'] as String?,
      isMain: json['is-main'] as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Component &&
          other.componentId == componentId &&
          other.class_ == class_ &&
          other.mfgName == mfgName &&
          other.productName == productName &&
          other.hardwareRev == hardwareRev &&
          other.partNumber == partNumber &&
          other.serialNumber == serialNumber &&
          other.isFru == isFru &&
          _listEquals(other.parent, parent) &&
          other.parentRelPos == parentRelPos &&
          other.isMain == isMain;

  @override
  int get hashCode => Object.hash(
        componentId,
        class_,
        mfgName,
        productName,
        hardwareRev,
        partNumber,
        serialNumber,
        isFru,
        Object.hashAll(parent),
        parentRelPos,
        isMain,
      );

  @override
  String toString() =>
      'Component(componentId: $componentId, class_: $class_)';
}

bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
