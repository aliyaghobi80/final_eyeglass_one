import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:flutter/services.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import 'dart:async';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final CartController cartController = Get.find();
  final OrderController orderController = Get.find();

  Timer? _timer;
  int _remainingMinutes = 9;
  int _remainingSeconds = 0;
  bool _isTimeout = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else if (_remainingMinutes > 0) {
          _remainingMinutes--;
          _remainingSeconds = 59;
        } else {
          _timer?.cancel();
          _isTimeout = true;
          _showTimeoutDialog();
        }
      });
    });
  }

  void _showTimeoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('زمان پرداخت به پایان رسید'),
        content: const Text('لطفاً دوباره تلاش کنید'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/home'); // Return to home screen
            },
            child: const Text('بستن'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await orderController.createOrder(
        address: _addressController.text,
        phone: _phoneController.text,
      );

      Get.back(); // برگشت به صفحه قبلی
    } catch (e) {
      // خطا در کنترلر مدیریت می‌شود
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isTimeout) {
      return const Scaffold(
        body: Center(child: Text('زمان پرداخت به پایان رسید')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('پرداخت'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
              ),
            ),
            child: Text(
              '${_remainingMinutes.toString().padLeft(2, '0')}:${_remainingSeconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // نمایش مبلغ کل
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مبلغ کل:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                      Text(
                        '${cartController.totalPrice.toString().seRagham()} تومان',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.greenAccent
                                  : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // فرم اطلاعات کارت
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اطلاعات کارت',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'شماره کارت',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final formatted = value.charRagham(
                                separator: '-',
                              );
                              if (formatted != value) {
                                _cardNumberController.text = formatted;
                                _cardNumberController
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(offset: formatted.length),
                                );
                              }
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفاً شماره کارت را وارد کنید';
                            }
                            if (value.replaceAll('-', '').length != 16) {
                              return 'شماره کارت باید 16 رقم باشد';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _expiryMonthController,
                                decoration: const InputDecoration(
                                  labelText: 'ماه',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'ماه را وارد کنید';
                                  }
                                  final month = int.tryParse(value);
                                  if (month == null ||
                                      month < 1 ||
                                      month > 12) {
                                    return 'ماه بین 1 تا 12 باشد';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '/',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _expiryYearController,
                                decoration: const InputDecoration(
                                  labelText: 'سال',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'سال را وارد کنید';
                                  }
                                  final year = int.tryParse(value);
                                  if (year == null || year < 04 || year > 99) {
                                    return 'سال بین 04 تا 99 باشد';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cvvController,
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفاً CVV را وارد کنید';
                            }
                            if (value.length != 4) {
                              return 'CVV باید 4 رقم باشد';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // فرم اطلاعات ارسال
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اطلاعات ارسال',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'آدرس کامل',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفاً آدرس را وارد کنید';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'شماره تلفن',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفاً شماره تلفن را وارد کنید';
                            }
                            if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
                              return 'شماره تلفن معتبر وارد کنید';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // دکمه پرداخت
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        orderController.isLoading.value
                            ? null
                            : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        orderController.isLoading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'پرداخت',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
