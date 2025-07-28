import 'dart:js' as js;
import 'dart:js_util';
import 'package:flutter/foundation.dart';

class MetaMaskService {
  // Cache the ethereum object to avoid repeated lookups
  static js.JsObject? _cachedEthereum;
  static bool _isInitialized = false;

  static void _initializeEthereum() {
    try {
      if (kIsWeb && js.context.hasProperty('ethereum')) {
        _cachedEthereum = js.context['ethereum'];
        _isInitialized = true;
      } else {
        _cachedEthereum = null;
        _isInitialized = false;
      }
    } catch (e) {
      print('Error initializing Ethereum object: $e');
      _cachedEthereum = null;
      _isInitialized = false;
    }
  }

  static js.JsObject? _getEthereumObject() {
    // Always refresh the ethereum object to handle MetaMask state changes
    try {
      if (kIsWeb && js.context.hasProperty('ethereum')) {
        final ethereum = js.context['ethereum'];
        if (ethereum != null) {
          _cachedEthereum = ethereum;
          return ethereum;
        }
      }
    } catch (e) {
      print('Error getting Ethereum object: $e');
    }
    _cachedEthereum = null;
    return null;
  }

  static bool get isMetaMaskAvailable {
    if (kIsWeb) {
      try {
        final ethereum = _getEthereumObject();
        return ethereum != null && 
               ethereum['isMetaMask'] == true;
      } catch (e) {
        print('Error checking MetaMask availability: $e');
        return false;
      }
    }
    return false;
  }

  static Future<String?> connectWallet() async {
    if (!isMetaMaskAvailable) {
      throw Exception('MetaMask is not available');
    }

    try {
      final ethereum = _getEthereumObject();
      if (ethereum == null) {
        throw Exception('Ethereum object is null');
      }

      // Check if request method exists
      if (!ethereum.hasProperty('request')) {
        throw Exception('MetaMask request method not available');
      }

      // Create a fresh request object each time
      final requestParams = js.JsObject.jsify({'method': 'eth_requestAccounts'});
      final requestResult = ethereum.callMethod('request', [requestParams]);

      // Handle both Promise and direct return cases with additional safety checks
      dynamic accounts;
      if (requestResult != null) {
        try {
          // Check if it's a thenable (Promise-like) object
          if (requestResult.hasProperty('then') && 
              requestResult['then'] != null) {
            // It's a Promise
            accounts = await promiseToFuture(requestResult);
          } else {
            // Direct return
            accounts = requestResult;
          }
        } catch (promiseError) {
          print('Promise handling error: $promiseError');
          // Fallback: try to treat as direct return
          accounts = requestResult;
        }
      }
      
      if (accounts != null) {
        if (accounts is List && accounts.isNotEmpty) {
          return accounts[0].toString();
        } else if (accounts.hasProperty('length') && accounts['length'] > 0) {
          return accounts[0].toString();
        }
      }
      return null;
    } catch (e) {
      print('Error connecting to MetaMask: $e');
      rethrow;
    }
  }

  static Future<String?> getCurrentAccount() async {
    if (!isMetaMaskAvailable) {
      return null;
    }

    try {
      final ethereum = _getEthereumObject();
      if (ethereum == null || !ethereum.hasProperty('request')) {
        return null;
      }

      final requestParams = js.JsObject.jsify({'method': 'eth_accounts'});
      final requestResult = ethereum.callMethod('request', [requestParams]);

      // Handle both Promise and direct return cases with additional safety checks
      dynamic accounts;
      if (requestResult != null) {
        try {
          // Check if it's a thenable (Promise-like) object
          if (requestResult.hasProperty('then') && 
              requestResult['then'] != null) {
            // It's a Promise
            accounts = await promiseToFuture(requestResult);
          } else {
            // Direct return
            accounts = requestResult;
          }
        } catch (promiseError) {
          print('Promise handling error: $promiseError');
          // Fallback: try to treat as direct return
          accounts = requestResult;
        }
      }
      
      if (accounts != null) {
        if (accounts is List && accounts.isNotEmpty) {
          return accounts[0].toString();
        } else if (accounts.hasProperty('length') && accounts['length'] > 0) {
          return accounts[0].toString();
        }
      }
      return null;
    } catch (e) {
      print('Error getting current account: $e');
      return null;
    }
  }

  static Future<String> sendTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    if (!isMetaMaskAvailable) {
      throw Exception('MetaMask is not available');
    }

    try {
      final ethereum = _getEthereumObject();
      if (ethereum == null || !ethereum.hasProperty('request')) {
        throw Exception('MetaMask request method not available');
      }

      final from = await getCurrentAccount();
      
      if (from == null) {
        throw Exception('No account connected');
      }

      final transactionParams = {
        'from': from,
        'to': to,
        'value': value,
        if (data != null) 'data': data,
      };

      final requestParams = js.JsObject.jsify({
        'method': 'eth_sendTransaction',
        'params': [transactionParams]
      });
      final requestResult = ethereum.callMethod('request', [requestParams]);

      // Handle both Promise and direct return cases with additional safety checks
      dynamic txHash;
      if (requestResult != null) {
        try {
          // Check if it's a thenable (Promise-like) object
          if (requestResult.hasProperty('then') && 
              requestResult['then'] != null) {
            // It's a Promise
            txHash = await promiseToFuture(requestResult);
          } else {
            // Direct return
            txHash = requestResult;
          }
        } catch (promiseError) {
          print('Promise handling error: $promiseError');
          // Fallback: try to treat as direct return
          txHash = requestResult;
        }
      }

      return txHash?.toString() ?? '';
    } catch (e) {
      print('Error sending transaction: $e');
      rethrow;
    }
  }

  static Future<String?> getChainId() async {
    if (!isMetaMaskAvailable) {
      return null;
    }

    try {
      final ethereum = _getEthereumObject();
      if (ethereum == null || !ethereum.hasProperty('request')) {
        return null;
      }

      final requestParams = js.JsObject.jsify({'method': 'eth_chainId'});
      final requestResult = ethereum.callMethod('request', [requestParams]);

      // Handle both Promise and direct return cases with additional safety checks
      dynamic chainId;
      if (requestResult != null) {
        try {
          // Check if it's a thenable (Promise-like) object
          if (requestResult.hasProperty('then') && 
              requestResult['then'] != null) {
            // It's a Promise
            chainId = await promiseToFuture(requestResult);
          } else {
            // Direct return
            chainId = requestResult;
          }
        } catch (promiseError) {
          print('Promise handling error: $promiseError');
          // Fallback: try to treat as direct return
          chainId = requestResult;
        }
      }
      
      return chainId?.toString();
    } catch (e) {
      print('Error getting chain ID: $e');
      return null;
    }
  }

  static void onAccountsChanged(Function(List<String>) callback) {
    if (!isMetaMaskAvailable) return;

    try {
      final ethereum = _getEthereumObject();
      if (ethereum != null && ethereum.hasProperty('on')) {
        ethereum.callMethod('on', ['accountsChanged', js.allowInterop((accounts) {
          if (accounts != null) {
            try {
              callback(List<String>.from(accounts));
            } catch (e) {
              print('Error in accounts changed callback: $e');
            }
          }
        })]);
      }
    } catch (e) {
      print('Error setting up accounts changed listener: $e');
    }
  }

  static void onChainChanged(Function(String) callback) {
    if (!isMetaMaskAvailable) return;

    try {
      final ethereum = _getEthereumObject();
      if (ethereum != null && ethereum.hasProperty('on')) {
        ethereum.callMethod('on', ['chainChanged', js.allowInterop((chainId) {
          if (chainId != null) {
            try {
              callback(chainId.toString());
            } catch (e) {
              print('Error in chain changed callback: $e');
            }
          }
        })]);
      }
    } catch (e) {
      print('Error setting up chain changed listener: $e');
    }
  }

  // Method to reset the service state (useful for reconnection scenarios)
  static void reset() {
    _cachedEthereum = null;
    _isInitialized = false;
  }
}

