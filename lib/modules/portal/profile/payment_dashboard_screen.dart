import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Make sure to add this dependency

class PaymentDashboardScreen extends StatefulWidget {
  @override
  State<PaymentDashboardScreen> createState() => _PaymentDashboardScreenState();
}

class _PaymentDashboardScreenState extends State<PaymentDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
        title: const Text('Payment'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle gear icon press
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3191),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.remove_red_eye, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Hide all', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Expected Revenue', style: TextStyle(color: Colors.white)),
                              Text('₦234,790.00', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoContainer('Paid', '₦230,790.00'),
                          _buildInfoContainer('Pending', '₦4,000.00'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Second section
              const Text('Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRecordContainer('Generate Receipt', 'assets/receipt_icon.svg', const Color(0xFF2D63FF)),
                  _buildRecordContainer('Expenditure', 'assets/expenditure_icon.svg', const Color(0xFF1E88E5)),
                ],
              ),
              const SizedBox(height: 24),
              // Third section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    'See all',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTransactionItem('Dennis John', '17:30 AM, Yesterday', 23790.00, 'grade 2'),
              _buildTransactionItem('Jane Smith', '10:45 AM, Today', -15000.00, 'grade 3'),
              _buildTransactionItem('Alex Johnson', '14:20 PM, Yesterday', 40000.00, 'grade 1'),
              _buildTransactionItem('Sarah Williams', '09:00 AM, 2 days ago', -5000.00, 'grade 2'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String title, String value) {
    return Container(
      width: 131,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF6E67AE),
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecordContainer(String title, String iconPath, Color backgroundColor) {
    return Container(
      width: 158,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath, width: 24, height: 24, color: Colors.white),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String name, String time, double amount, String grade) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset('assets/transaction_icon.svg', width: 24, height: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${amount >= 0 ? '+' : '-'} ₦${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: amount >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(grade, style: const TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}