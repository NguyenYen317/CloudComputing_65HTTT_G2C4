part of '../main.dart';

class MlProvider extends ChangeNotifier {
  MlPredictions? predictions;
  bool loading = false;
  bool actionLoading = false;
  String? error;

  Future<void> fetchPredictions(String? token) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.get(
        ApiEndpoints.uri(ApiEndpoints.adminMlPredictions),
        headers: _providerAuthHeaders(token),
      );
      final data = _providerJsonMap(response.body);

      if (response.statusCode == 200) {
        predictions = MlPredictions.fromJson(data);
      } else {
        predictions = null;
        error = _providerMessage(data, 'Không tải được dữ liệu ML.');
      }
    } catch (err) {
      predictions = null;
      error = 'Không kết nối được API ML: $err';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> trainModel(String? token) {
    return _runMlAction(
      endpoint: '/admin/train-ml-model',
      token: token,
      reloadAfterSuccess: true,
    );
  }

  Future<bool> updatePredictions(String? token) {
    return _runMlAction(
      endpoint: '/admin/update-ml-predictions',
      token: token,
      applyResponseData: true,
    );
  }

  Future<bool> _runMlAction({
    required String endpoint,
    required String? token,
    bool reloadAfterSuccess = false,
    bool applyResponseData = false,
  }) async {
    actionLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.post(
        ApiEndpoints.uri(endpoint),
        headers: _providerAuthHeaders(token),
      );
      final data = _providerJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (applyResponseData && data['data'] != null) {
          predictions = MlPredictions.fromJson(
            Map<String, dynamic>.from(data['data']),
          );
        } else if (reloadAfterSuccess) {
          await fetchPredictions(token);
        }
        return true;
      }

      error = _providerMessage(data, 'Thao tác ML thất bại');
      return false;
    } catch (err) {
      error = 'Không gọi được API ML: $err';
      return false;
    } finally {
      actionLoading = false;
      notifyListeners();
    }
  }
}
