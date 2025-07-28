import 'dart:js' as js;
import 'dart:js_util';
import 'package:flutter/foundation.dart';

class MetaMaskService {
  static bool get isMetaMaskAvailable {
    if (kIsWeb) {
      try {
        return js.context.hasProperty('ethereum') && 
               js.context['ethereum'] != null &&
               js.context['ethereum']['isMetaMask'] == true;
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
      final ethereum = js.context['ethereum'];
      if (ethereum == null) {
        throw Exception('Ethereum object is null');
      }

      // Check if request method exists
      if (!ethereum.hasProperty('request')) {
        throw Exception('MetaMask request method not available');
      }

      final requestResult = ethereum.callMethod('request', [
        js.JsObject.jsify({'method': 'eth_requestAccounts'})
      ]);

      // Handle both Promise and direct return cases
      dynamic accounts;
      if (requestResult != null && requestResult.hasProperty('then')) {
        // It's a Promise
        accounts = await promiseToFuture(requestResult);
      } else {
        // Direct return
        accounts = requestResult;
      }
      
      if (accounts != null && accounts is List && accounts.isNotEmpty) {
        return accounts[0].toString();
      } else if (accounts != null && accounts.hasProperty('length') && accounts['length'] > 0) {
        return accounts[0].toString();
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
      final ethereum = js.context['ethereum'];
      if (ethereum == null || !ethereum.hasProperty('request')) {
        return null;
      }

      final requestResult = ethereum.callMethod('request', [
        js.JsObject.jsify({'method': 'eth_accounts'})
      ]);

      // Handle both Promise and direct return cases
      dynamic accounts;
      if (requestResult != null && requestResult.hasProperty('then')) {
        // It's a Promise
        accounts = await promiseToFuture(requestResult);
      } else {
        // Direct return
        accounts = requestResult;
      }
      
      if (accounts != null && accounts is List && accounts.isNotEmpty) {
        return accounts[0].toString();
      } else if (accounts != null && accounts.hasProperty('length') && accounts['length'] > 0) {
        return accounts[0].toString();
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
      final ethereum = js.context['ethereum'];
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

      final requestResult = ethereum.callMethod('request', [
        js.JsObject.jsify({
          'method': 'eth_sendTransaction',
          'params': [transactionParams]
        })
      ]);

      // Handle both Promise and direct return cases
      dynamic txHash;
      if (requestResult != null && requestResult.hasProperty('then')) {
        // It's a Promise
        txHash = await promiseToFuture(requestResult);
      } else {
        // Direct return
        txHash = requestResult;
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
      final ethereum = js.context['ethereum'];
      if (ethereum == null || !ethereum.hasProperty('request')) {
        return null;
      }

      final requestResult = ethereum.callMethod('request', [
        js.JsObject.jsify({'method': 'eth_chainId'})
      ]);

      // Handle both Promise and direct return cases
      dynamic chainId;
      if (requestResult != null && requestResult.hasProperty('then')) {
        // It's a Promise
        chainId = await promiseToFuture(requestResult);
      } else {
        // Direct return
        chainId = requestResult;
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
      final ethereum = js.context['ethereum'];
      if (ethereum != null && ethereum.hasProperty('on')) {
        ethereum.callMethod('on', ['accountsChanged', js.allowInterop((accounts) {
          if (accounts != null) {
            callback(List<String>.from(accounts));
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
      final ethereum = js.context['ethereum'];
      if (ethereum != null && ethereum.hasProperty('on')) {
        ethereum.callMethod('on', ['chainChanged', js.allowInterop((chainId) {
          if (chainId != null) {
            callback(chainId.toString());
          }
        })]);
      }
    } catch (e) {
      print('Error setting up chain changed listener: $e');
    }
  }
}

