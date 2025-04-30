import 'package:eyewear/utils/my_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar(
        'خطا',
        'امکان باز کردن لینک وجود ندارد',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درباره ما'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'فروشگاه عینک ما',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ارائه دهنده بهترین محصولات عینک',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'درباره ما',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ).rtl(),
                  const SizedBox(height: 10),
                  const Text(
                    'ما با ارائه بهترین و جدیدترین مدل‌های عینک، تجربه‌ای منحصر به فرد از خرید آنلاین را برای شما فراهم می‌کنیم. کیفیت بالا، قیمت مناسب و ارسال سریع از ویژگی‌های اصلی ماست.',
                    style: TextStyle(fontSize: 16),
                  ).rtl(),
                  const SizedBox(height: 30),
                  const Text(
                    'ویژگی‌های ما',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ).rtl(),
                  const SizedBox(height: 15),
                  _buildFeatureCard(
                    icon: Icons.verified,
                    title: 'کیفیت تضمینی',
                    description:
                        'تمامی محصولات ما از برترین برندها و با کیفیت عالی عرضه می‌شوند',
                  ),
                  _buildFeatureCard(
                    icon: Icons.local_shipping,
                    title: 'ارسال سریع',
                    description:
                        'ارسال محصولات در کمترین زمان ممکن به تمام نقاط کشور',
                  ),
                  _buildFeatureCard(
                    icon: Icons.support_agent,
                    title: 'پشتیبانی ۲۴/۷',
                    description:
                        'تیم پشتیبانی ما در تمام ساعات شبانه روز آماده پاسخگویی به شماست',
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'راه‌های ارتباطی',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ).rtl(),
                  const SizedBox(height: 15),
                  _buildContactCard(
                    icon: Icons.phone,
                    title: 'تماس با ما',
                    subtitle: '09174320243',
                    onTap: () => _launchUrl('tel:09174320243'),
                  ),
                  _buildContactCard(
                    icon: Icons.email,
                    title: 'ایمیل',
                    subtitle: 'aymix09@gmail.com',
                    onTap: () => _launchUrl('mailto:aymix09@gmail.com'),
                  ),
                  _buildContactCard(
                    icon: Icons.location_on,
                    title: 'آدرس',
                    subtitle: 'شیراز، خیابان ولیعصر، پلاک ۱۲۳',
                    onTap: () => _launchUrl('https://maps.google.com'),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('بازگشت'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ).rtl(),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ).rtl(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title).rtl(),
        subtitle: Text(subtitle).rtl(),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
