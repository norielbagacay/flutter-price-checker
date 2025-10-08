import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Take your growing business to the next level with',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TinkerPro POS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                  height: 1.2,
                ),
              ),
              const SizedBox(height:30),
              
              // Faster Sales
              _buildBenefitCard(
                context,
                icon: Icons.flash_on,
                title: 'Faster Sales',
                description: 'Turn every long line into smooth, lightning-fast checkouts that keep customers happy and coming back.',
              ),
              const SizedBox(height: 32),
              
              // Bigger Profits
              _buildBenefitCard(
                context,
                icon: Icons.trending_up,
                title: 'Bigger Profits',
                description: 'Stop letting human errors eat your income every sale, every peso, perfectly recorded and secured.',
              ),
              const SizedBox(height: 32),
              
              // Less Stress
              _buildBenefitCard(
                context,
                icon: Icons.self_improvement,
                title: 'Less Stress',
                description: 'No more late-night reconciliations or messy notebooks your business runs itself effortlessly.',
              ),
              const SizedBox(height: 48),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                                  child: ElevatedButton(
                  onPressed: () {
                    _showContactDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Get FREE Quote',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildBenefitCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.orange[700],
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void _showContactDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.1,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: screenHeight * 0.8,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange[50]!, Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[600],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.note_add_outlined,
                      size: isSmallScreen ? 32 : 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 18),
                  Text(
                    'Get FREE Quote',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  _buildContactItem(
                    context,
                    icon: Icons.phone,
                    label: 'Phone',
                    value: '09621324545',
                    isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildContactItem(
                    context,
                    icon: Icons.email,
                    label: 'Email',
                    value: 'tinkerpro.infotech@gmail.com',
                    isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildContactItem(
                    context,
                    icon: Icons.facebook,
                    label: 'Facebook',
                    value: 'TinkerPro POS',
                    isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildContactItem(
                    context,
                    icon: FontAwesomeIcons.youtube,
                    label: 'Youtube',
                    value: 'TinkerPro POS',
                    isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildContactItem(
                    context,
                    icon: Icons.language,
                    label: 'Demo Link',
                    value: 'https://tinkerpro.com.ph/demo',
                    isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  Text(
                    'Tip: Message us on Facebook to get FREE instant quote.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),  
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 24 : 32,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildContactItem(
    BuildContext context,
    bool isSmallScreen, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.orange[700],
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy,
              size: isSmallScreen ? 16 : 18,
              color: Colors.grey[600],
            ),
            padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
            constraints: BoxConstraints(
              minWidth: isSmallScreen ? 32 : 40,
              minHeight: isSmallScreen ? 32 : 40,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 16,
                    vertical: 10,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}