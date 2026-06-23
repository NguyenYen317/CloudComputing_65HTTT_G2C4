// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

part of '../main.dart';

extension BigQueryServiceMethods on _HomePageState {
  Future<void> fetchBigQueryEvents() async {
    setState(() {
      bigQueryLoading = true;
      bigQueryError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/admin/bigquery-events'),
        headers: {if (authToken != null) 'Authorization': 'Bearer $authToken'},
      );
      final List data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          bigQueryEvents = data
              .map(
                (item) => BigQueryOrderEvent.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        });
      } else {
        setState(() {
          bigQueryEvents = [];
          bigQueryError = 'Không tải được dữ liệu BigQuery.';
        });
      }
    } catch (error) {
      setState(() {
        bigQueryEvents = [];
        bigQueryError = 'Không kết nối được API BigQuery: $error';
      });
    } finally {
      if (mounted) setState(() => bigQueryLoading = false);
    }
  }
}
