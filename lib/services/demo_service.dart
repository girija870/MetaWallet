import 'dart:math';

class DemoService {
  static const String demoAccount = '0x742d35Cc6634C0532925a3b8D4C9db96590b5';
  static const String demoChainId = '0x1'; // Ethereum Mainnet
  static bool _isConnected = false;
  
  static bool get isConnected => _isConnected;
  
  static Future<String?> connectWallet() async {
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));
    _isConnected = true;
    return demoAccount;
  }
  
  static Future<String?> getCurrentAccount() async {
    return _isConnected ? demoAccount : null;
  }
  
  static Future<String> sendTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    // Simulate transaction processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate a mock transaction hash
    final random = Random();
    final hash = '0x${random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}'
                 '${random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}'
                 '${random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}'
                 '${random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}';
    
    return hash;
  }
  
  static Future<String?> getChainId() async {
    return _isConnected ? demoChainId : null;
  }
  
  static void disconnect() {
    _isConnected = false;
  }
}

