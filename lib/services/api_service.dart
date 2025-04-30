// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../models/product.dart';

class ApiService {
  // متد ثبت‌نام

  Future<User> register({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    File? profilePicture,
  }) async {
    try {
      var uri = Uri.parse(Constants.registerUrl);
      var request = http.MultipartRequest('POST', uri);

      // اضافه کردن فیلدهای متنی
      request.fields['username'] = username;
      request.fields['password'] = password;
      request.fields['email'] = email;
      request.fields['first_name'] = firstName ?? '';
      request.fields['last_name'] = lastName ?? '';
      if (phone != null && phone.isNotEmpty) {
        request.fields['phone'] = phone.trim();
      }

      // اضافه کردن فایل تصویر (اگه وجود داشته باشه)
      if (profilePicture != null) {
        var stream = http.ByteStream(profilePicture.openRead());
        var length = await profilePicture.length();
        var multipartFile = http.MultipartFile(
          'profile_picture', // نام فیلد باید با بک‌اند (SignupSerializer) مطابقت داشته باشه
          stream,
          length,
          filename: profilePicture.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // ارسال درخواست
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final userData = User.fromJson({
          ...responseData['user'] as Map<String, dynamic>,
          'access_token': responseData['access_token'] ?? '',
          'refresh_token': responseData['refresh_token'] ?? '',
        });
        Get.snackbar('موفقیت', 'ثبت‌نام با موفقیت انجام شد');
        print("userData: $userData");
        print("userImage: ${userData.profilePictureUrl}");
        return userData;
      } else {
        throw Exception('ثبت‌نام: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('Error in register: $e');
      throw Exception(' ثبت‌نام: $e');
    }
  }

  /// 📌 متد ورود به سیستم
  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("Login response: $responseData"); // برای دیباگ

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', responseData['access_token']);
        await prefs.setString('refresh_token', responseData['refresh_token']);

        final Map<String, dynamic> userData = {
          ...responseData['user'] as Map<String, dynamic>,
          'access_token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
        };

        final user = User.fromJson(userData);
        print("Created user object: ${user.toJson()}"); // برای دیباگ
        return user;
      } else {
        throw Exception('خطا در ورود: ${response.body}');
      }
    } catch (e) {
      print("Login error: $e"); // برای دیباگ
      throw Exception('خطا در ورود: $e');
    }
  }

  /// 📌 متد لاگ‌اوت
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      throw Exception('توکن‌ها یافت نشدند');
    }

    try {
      final response = await http.post(
        Uri.parse(Constants.logoutUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
      }
    } catch (e) {
      throw Exception('خطا در خروج: $e');
    }
  }

  /// 📌 متد بررسی انقضای توکن
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(payload)),
      );
      final exp = jsonDecode(decoded)['exp'];

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp < now;
    } catch (_) {
      return true;
    }
  }

  /// 📌 متد دریافت `access_token` معتبر
  Future<String?> getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (isTokenExpired(accessToken!)) {
      accessToken = await refreshAccessToken(refreshToken!);
      await prefs.setString('access_token', accessToken);
    }

    return accessToken;
  }

  /// 📌 متد رفرش توکن
  Future<String> refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['access'];
      } else {
        throw Exception('خطا در به‌روزرسانی توکن: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطا در به‌روزرسانی توکن: $e');
    }
  }

  /// 📌 متد عمومی برای ارسال درخواست با احراز هویت
  Future<http.Response> sendRequestWithAuth(
    String method,
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      String? accessToken = await getValidAccessToken();

      if (method.toUpperCase() == 'PUT') {
        // برای درخواست‌های PUT از MultipartRequest استفاده می‌کنیم
        var request = http.MultipartRequest('PUT', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $accessToken';
        request.headers['Accept'] = 'application/json';

        if (body != null) {
          if (body is String) {
            request.fields['data'] = body;
          } else {
            // تبدیل داده‌ها به رشته‌های متنی
            (body as Map<String, dynamic>).forEach((key, value) {
              request.fields[key] = value.toString();
            });
          }
        }

        print("Sending PUT request to: $url");
        print("Method: PUT");
        print("Fields: ${request.fields}");
        print("Headers: ${request.headers}");

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode >= 400) {
          String errorMessage;
          try {
            final errorData = jsonDecode(utf8.decode(response.bodyBytes));
            errorMessage =
                errorData['message'] ?? errorData['detail'] ?? 'خطای نامشخص';
          } catch (_) {
            errorMessage = 'خطا در ارتباط با سرور';
          }
          throw Exception(errorMessage);
        }

        return response;
      } else {
        // برای سایر متدها از روش قبلی استفاده می‌کنیم
        final defaultHeaders = {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        };

        final finalHeaders = {...defaultHeaders, ...?headers};

        print("Sending request to: $url");
        print("Method: $method");
        print("Headers: $finalHeaders");

        http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(Uri.parse(url), headers: finalHeaders);
            break;
          case 'POST':
            response = await http.post(
              Uri.parse(url),
              headers: finalHeaders,
              body: body is String ? body : jsonEncode(body),
            );
            break;
          case 'DELETE':
            response = await http.delete(Uri.parse(url), headers: finalHeaders);
            break;
          default:
            throw Exception('متد درخواست نامعتبر است');
        }

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode >= 400) {
          String errorMessage;
          try {
            final errorData = jsonDecode(utf8.decode(response.bodyBytes));
            errorMessage =
                errorData['message'] ?? errorData['detail'] ?? 'خطای نامشخص';
          } catch (_) {
            errorMessage = 'خطا در ارتباط با سرور';
          }
          throw Exception(errorMessage);
        }

        return response;
      }
    } catch (e) {
      print("Request error: $e");
      throw Exception('خطا در ارسال درخواست: $e');
    }
  }

  /// 📌 دریافت لیست محصولات
  Future<List<Product>> getProducts() async {
    final response = await sendRequestWithAuth('GET', Constants.productListUrl);

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      final products =
          (data['products'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
      return products;
    } else {
      throw Exception(
        'Failed to load products: ${utf8.decode(response.bodyBytes)}',
      );
    }
  }

  /// 📌 اضافه کردن محصول جدید
  Future<void> addProduct(Map<String, dynamic> productData) async {
    String? accessToken = await getValidAccessToken();
    var uri = Uri.parse(Constants.addProductUrl);

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';

    // اضافه کردن فیلدهای متنی
    request.fields['name'] = productData['name'];
    request.fields['description'] = productData['description'];
    request.fields['price'] = productData['price'].toString();
    request.fields['sale_price'] = productData['sale_price'].toString();
    request.fields['is_sale'] = productData['is_sale'].toString();
    request.fields['is_available'] = productData['is_available'].toString();
    request.fields['category'] = productData['category'].toString();

    // اضافه کردن فایل تصویر
    if (productData['image'] != null) {
      var file = productData['image'] as File;
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();

      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: file.path.split('/').last,
      );

      request.files.add(multipartFile);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to add product: ${utf8.decode(response.bodyBytes)}',
      );
    }
  }

  /// 📌 آپدیت محصول
  Future<void> updateProduct(
    int productId,
    Map<String, dynamic> productData, {
    File? imageFile,
  }) async {
    print('Updating product $productId');
    print('Product data: $productData');
    if (imageFile != null) {
      print('Image file: ${imageFile.path}');
    }

    try {
      final token = await getValidAccessToken();

      // Convert all values to strings
      final jsonData = {
        'name': productData['name'].toString(),
        'description': productData['description'].toString(),
        'price': productData['price'].toString(),
        'sale_price': productData['sale_price'].toString(),
        'is_sale': productData['is_sale'].toString(),
        'is_available': productData['is_available'].toString(),
        'category': productData['category'].toString(),
      };

      if (imageFile != null) {
        print('Sending multipart request with image');
        final url = Uri.parse('${Constants.editProductUrl}$productId/');
        var request = http.MultipartRequest('PUT', url);
        request.headers['Authorization'] = 'Bearer $token';

        // Add text fields
        jsonData.forEach((key, value) {
          request.fields[key] = value;
        });

        // Add image file
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        print('Request fields: ${request.fields}');
        print('Sending request...');

        final response = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('درخواست به سرور بیش از حد طول کشید');
          },
        );
        final responseData = await response.stream.bytesToString();
        print('Response status: ${response.statusCode}');
        print('Response data: $responseData');

        if (response.statusCode != 200) {
          throw Exception('خطا در به‌روزرسانی محصول: $responseData');
        }
      } else {
        print('Sending regular request without image');
        final response = await sendRequestWithAuth(
          'PUT',
          '${Constants.editProductUrl}$productId/',
          body: jsonData,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('درخواست به سرور بیش از حد طول کشید');
          },
        );

        if (response.statusCode != 200) {
          throw Exception('خطا در به‌روزرسانی محصول: ${response.body}');
        }
      }
    } catch (e) {
      print('Error in updateProduct: $e');
      print('Error type: ${e.runtimeType}');
      print('Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// 📌 حذف محصول
  Future<void> deleteProduct(int id) async {
    final response = await sendRequestWithAuth(
      'DELETE',
      Constants.getDeleteProductUrl(id),
    );

    if (response.statusCode != 204) {
      throw Exception('خطا در حذف محصول');
    }
  }

  /// 📌 دریافت لیست دسته‌بندی‌ها
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await sendRequestWithAuth(
        'GET',
        Constants.categoriesUrl,
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedResponse);
        return List<Map<String, dynamic>>.from(data['categories'] ?? []);
      } else {
        throw Exception(
          'خطا در دریافت دسته‌بندی‌ها: ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e) {
      throw Exception('خطا در دریافت دسته‌بندی‌ها');
    }
  }

  /// 📌 اضافه کردن دسته‌بندی جدید
  Future<Map<String, dynamic>> addCategory(String name) async {
    try {
      final response = await sendRequestWithAuth(
        'POST',
        Constants.addCategoryUrl,
        body: {'name': name},
      );

      if (response.statusCode == 201) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse);
      } else {
        throw Exception(
          'خطا در افزودن دسته‌بندی: ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e) {
      throw Exception('خطا در افزودن دسته‌بندی');
    }
  }

  /// 📌 ویرایش دسته‌بندی
  Future<Map<String, dynamic>> editCategory(int categoryId, String name) async {
    try {
      final response = await sendRequestWithAuth(
        'PUT',
        Constants.getEditCategoryUrl(categoryId),
        body: {'name': name},
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse);
      } else {
        throw Exception(
          'خطا در ویرایش دسته‌بندی: ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e) {
      throw Exception('خطا در ویرایش دسته‌بندی');
    }
  }

  /// 📌 حذف دسته‌بندی
  Future<void> deleteCategory(int categoryId) async {
    try {
      final response = await sendRequestWithAuth(
        'DELETE',
        Constants.getDeleteCategoryUrl(categoryId),
      );

      if (response.statusCode != 204) {
        throw Exception(
          'خطا در حذف دسته‌بندی: ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e) {
      throw Exception('خطا در حذف دسته‌بندی');
    }
  }

  /// 📌 متد به‌روزرسانی پروفایل کاربر
  Future<User> updateProfile({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    File? profilePicture,
  }) async {
    try {
      var uri = Uri.parse(Constants.updateProfileUrl);
      var request = http.MultipartRequest('PUT', uri);

      // اضافه کردن هدرهای UTF-8
      request.headers['Content-Type'] = 'multipart/form-data; charset=utf-8';
      request.headers['Accept'] = 'application/json';
      request.headers['Accept-Charset'] = 'utf-8';

      // اضافه کردن فیلدهای متنی
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      if (phone != null) {
        request.fields['phone'] = phone;
      }

      // اضافه کردن فایل تصویر (اگه وجود داشته باشه)
      if (profilePicture != null) {
        var stream = http.ByteStream(profilePicture.openRead());
        var length = await profilePicture.length();
        var multipartFile = http.MultipartFile(
          'profile_picture',
          stream,
          length,
          filename: profilePicture.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // اضافه کردن توکن احراز هویت
      String? accessToken = await getValidAccessToken();
      request.headers['Authorization'] = 'Bearer $accessToken';

      print("Sending profile update request to: ${request.url}");
      print("Fields: ${request.fields}");
      print("Files: ${request.files.length}");
      print("Headers: ${request.headers}");

      // ارسال درخواست
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Profile update response status: ${response.statusCode}");
      print("Profile update response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> responseData = jsonDecode(decodedResponse);
        return User.fromJson(responseData);
      } else {
        final decodedError = utf8.decode(response.bodyBytes);
        final errorBody = jsonDecode(decodedError);
        throw Exception(
          'خطا در به‌روزرسانی پروفایل: ${errorBody['detail'] ?? errorBody['message'] ?? 'خطای نامشخص'}',
        );
      }
    } catch (e) {
      print("Profile update error: $e");
      if (e.toString().contains('توکن')) {
        // اگر خطای توکن است، توکن را رفرش کنیم و دوباره تلاش کنیم
        final prefs = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString('refresh_token');
        if (refreshToken != null) {
          final newAccessToken = await refreshAccessToken(refreshToken);
          await prefs.setString('access_token', newAccessToken);
          // دوباره تلاش می‌کنیم
          return updateProfile(
            username: username,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            profilePicture: profilePicture,
          );
        }
      }
      throw Exception('خطا در به‌روزرسانی پروفایل: $e');
    }
  }

  Future<http.Response> getProfile() async {
    print('Sending request to: ${Constants.profileUrl}');
    print('Method: GET');

    final headers = await _getHeaders();
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse(Constants.profileUrl),
      headers: headers,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }
}
