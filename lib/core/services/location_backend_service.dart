import '../config/api_config.dart';
import 'api_service.dart';

class StateModel {
  final int id;
  final String name;
  final String code;

  const StateModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class CityModel {
  final int id;
  final int stateId;
  final String name;
  final double latitude;
  final double longitude;

  const CityModel({
    required this.id,
    required this.stateId,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int? ?? 0,
      stateId: json['stateId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AreaModel {
  final int id;
  final int cityId;
  final String name;
  final String? pincode;

  const AreaModel({
    required this.id,
    required this.cityId,
    required this.name,
    this.pincode,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as int? ?? 0,
      cityId: json['cityId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pincode: json['pincode'] as String?,
    );
  }
}

class LocationBackendService {
  LocationBackendService._();
  static final LocationBackendService instance = LocationBackendService._();

  Future<List<StateModel>> getStates() async {
    final res = await ApiService.instance.get<List<StateModel>>(
      url: ApiConfig.states,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => StateModel.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <StateModel>[];
      },
      requiresAuth: false,
    );

    return res.data ?? [];
  }

  Future<List<CityModel>> getCities({int? stateId}) async {
    final queryParams = stateId != null ? {'stateId': stateId.toString()} : null;

    final res = await ApiService.instance.get<List<CityModel>>(
      url: ApiConfig.cities,
      queryParams: queryParams,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => CityModel.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <CityModel>[];
      },
      requiresAuth: false,
    );

    return res.data ?? [];
  }

  Future<List<AreaModel>> getAreas({required int cityId}) async {
    final res = await ApiService.instance.get<List<AreaModel>>(
      url: ApiConfig.areas,
      queryParams: {'cityId': cityId.toString()},
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => AreaModel.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <AreaModel>[];
      },
      requiresAuth: false,
    );

    return res.data ?? [];
  }
}
