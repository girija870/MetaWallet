import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/metamask_service.dart';
import 'services/demo_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WalletHomePage(),
    );
  }
}

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  String? connectedAccount;
  String? chainId;
  bool isConnecting = false;
  bool isSending = false;
  String? lastTransactionHash;
  bool isDemoMode = false;
  
  final TextEditingController _toAddressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    // Enable demo mode if MetaMask is not available
    if (!MetaMaskService.isMetaMaskAvailable) {
      isDemoMode = true;
      // Automatically connect demo wallet
      _autoConnectDemoWallet();
    } else {
      _checkConnection();
    }
  }

  void _setupEventListeners() {
    MetaMaskService.onAccountsChanged((accounts) {
      setState(() {
        connectedAccount = accounts.isNotEmpty ? accounts.first : null;
      });
    });

    MetaMaskService.onChainChanged((newChainId) {
      setState(() {
        chainId = newChainId;
      });
    });
  }

  Future<void> _autoConnectDemoWallet() async {
    try {
      final account = await DemoService.connectWallet();
      final chain = await DemoService.getChainId();
      setState(() {
        connectedAccount = account;
        chainId = chain;
      });
    } catch (e) {
      print('Failed to auto-connect demo wallet: $e');
    }
  }

  Future<void> _checkConnection() async {
    if (isDemoMode) {
      final account = await DemoService.getCurrentAccount();
      final chain = await DemoService.getChainId();
      setState(() {
        connectedAccount = account;
        chainId = chain;
      });
    } else if (MetaMaskService.isMetaMaskAvailable) {
      final account = await MetaMaskService.getCurrentAccount();
      final chain = await MetaMaskService.getChainId();
      setState(() {
        connectedAccount = account;
        chainId = chain;
      });
    }
  }

  Future<void> _connectWallet() async {
    setState(() {
      isConnecting = true;
    });

    try {
      String? account;
      String? chain;
      
      if (isDemoMode) {
        account = await DemoService.connectWallet();
        chain = await DemoService.getChainId();
        _showSnackBar('Demo wallet connected successfully!');
      } else if (MetaMaskService.isMetaMaskAvailable) {
        account = await MetaMaskService.connectWallet();
        chain = await MetaMaskService.getChainId();
        _showSnackBar('MetaMask wallet connected successfully!');
      } else {
        _showSnackBar('MetaMask is not available. Please install MetaMask extension.');
        return;
      }
      
      setState(() {
        connectedAccount = account;
        chainId = chain;
      });
    } catch (e) {
      _showSnackBar('Failed to connect wallet: $e');
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  Future<void> _sendTransaction() async {
    if (connectedAccount == null) {
      _showSnackBar('Please connect your wallet first');
      return;
    }

    if (_toAddressController.text.isEmpty || _amountController.text.isEmpty) {
      _showSnackBar('Please fill in recipient address and amount');
      return;
    }

    setState(() {
      isSending = true;
      lastTransactionHash = null;
    });

    try {
      String txHash;
      
      if (isDemoMode) {
        txHash = await DemoService.sendTransaction(
          to: _toAddressController.text,
          value: _amountController.text,
          data: _dataController.text.isNotEmpty ? _dataController.text : null,
        );
        _showSnackBar('Demo transaction sent! Hash: ${txHash.substring(0, 10)}...');
      } else {
        // Convert ETH amount to Wei (multiply by 10^18)
        final amountInWei = (double.parse(_amountController.text) * 1e18).toInt();
        final valueHex = '0x${amountInWei.toRadixString(16)}';

        txHash = await MetaMaskService.sendTransaction(
          to: _toAddressController.text,
          value: valueHex,
          data: _dataController.text.isNotEmpty ? _dataController.text : null,
        );
        _showSnackBar('Transaction sent! Hash: ${txHash.substring(0, 10)}...');
      }

      setState(() {
        lastTransactionHash = txHash;
      });
      
      // Clear form
      _toAddressController.clear();
      _amountController.clear();
      _dataController.clear();
      
    } catch (e) {
      _showSnackBar('Transaction failed: $e');
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Wallet App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MetaMask Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDemoMode 
                            ? Icons.science 
                            : (MetaMaskService.isMetaMaskAvailable 
                              ? Icons.check_circle 
                              : Icons.error),
                          color: isDemoMode 
                            ? Colors.blue 
                            : (MetaMaskService.isMetaMaskAvailable 
                              ? Colors.green 
                              : Colors.red),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDemoMode 
                            ? 'Demo Mode Active' 
                            : (MetaMaskService.isMetaMaskAvailable 
                              ? 'MetaMask Available' 
                              : 'MetaMask Not Available'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    if (isDemoMode) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Running in demo mode for testing purposes',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (chainId != null) ...[
                      const SizedBox(height: 8),
                      Text('Chain ID: $chainId'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Wallet Connection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Connection',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (connectedAccount != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Connected: ${connectedAccount!.substring(0, 6)}...${connectedAccount!.substring(connectedAccount!.length - 4)}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyToClipboard(connectedAccount!),
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text('No wallet connected'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isConnecting ? null : _connectWallet,
                        child: isConnecting 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isDemoMode ? 'Connect Demo Wallet' : 'Connect MetaMask'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Send Transaction Card
            if (connectedAccount != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Transaction',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _toAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Recipient Address',
                          hintText: '0x...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (ETH)',
                          hintText: '0.001',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dataController,
                        decoration: const InputDecoration(
                          labelText: 'Data (Optional)',
                          hintText: '0x...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSending ? null : _sendTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isSending 
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Sending...'),
                                ],
                              )
                            : const Text('Send Transaction'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Transaction Result Card
            if (lastTransactionHash != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Transaction Sent',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Hash: $lastTransactionHash',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyToClipboard(lastTransactionHash!),
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _toAddressController.dispose();
    _amountController.dispose();
    _dataController.dispose();
    super.dispose();
  }
}

