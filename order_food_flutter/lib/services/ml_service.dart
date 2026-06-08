// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../main.dart';

extension MlServiceMethods on _HomePageState {
  Future<void> fetchMlPredictions() async {
    setState(() {
      mlLoading = true;
      mlError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/admin/ml-predictions'),
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        setState(() => mlPredictions = MlPredictions.fromJson(data));
      } else {
        setState(() {
          mlPredictions = null;
          mlError = data['message']?.toString() ?? 'Không tải được dữ liệu ML.';
        });
      }
    } catch (error) {
      setState(() {
        mlPredictions = null;
        mlError = 'Không kết nối được API ML: $error';
      });
    } finally {
      if (mounted) setState(() => mlLoading = false);
    }
  }

  Future<void> trainMlModel() async {
    await runMlAdminAction(
      endpoint: '/admin/train-ml-model',
      successMessage: 'Huấn luyện model thành công',
    );
  }

  Future<void> updateMlPredictions() async {
    await runMlAdminAction(
      endpoint: '/admin/update-ml-predictions',
      successMessage: 'Cập nhật dự đoán ML thành công',
      applyResponseData: true,
    );
  }

  Future<void> runMlAdminAction({
    required String endpoint,
    required String successMessage,
    bool applyResponseData = false,
  }) async {
    setState(() {
      mlActionLoading = true;
      mlError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl$endpoint'),
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (applyResponseData && data['data'] != null) {
          setState(
            () => mlPredictions = MlPredictions.fromJson(
              Map<String, dynamic>.from(data['data']),
            ),
          );
        } else {
          await fetchMlPredictions();
        }
        showMessage(data['message']?.toString() ?? successMessage);
      } else {
        final message = data['message']?.toString() ?? 'Thao tác ML thất bại';
        setState(() => mlError = message);
        showMessage(message);
      }
    } catch (error) {
      final message = 'Không gọi được API ML: $error';
      setState(() => mlError = message);
      showMessage(message);
    } finally {
      if (mounted) setState(() => mlActionLoading = false);
    }
  }
}
