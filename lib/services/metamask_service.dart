import 'dart:js' as js;
import 'dart:js_util';
import 'package:flutter/foundation.dart';

class MetaMaskService {
  static bool get isMetaMaskAvailable {
    if (kIsWeb) {
      return js.context.hasProperty('ethereum') && 
             js.context['ethereum'] != null &&
             js.context['ethereum']['isMetaMask'] == true;
    }
    return false;
  }

  static Future<String?> connectWallet() async {
    if (!isMetaMaskAvailable) {
      throw Exception('MetaMask is not available');
    }

    try {
      final ethereum = js.context['ethereum'];
      final accounts = await promiseToFuture(
        ethereum.callMethod('request', [
          js.JsObject.jsify({'method': 'eth_requestAccounts'})
        ])
      );
      
      if (accounts != null && accounts.length > 0) {
        return accounts[0];
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
      final accounts = await promiseToFuture(
        ethereum.callMethod('request', [
          js.JsObject.jsify({'method': 'eth_accounts'})
        ])
      );
      
      if (accounts != null && accounts.length > 0) {
        return accounts[0];
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

      final txHash = await promiseToFuture(
        ethereum.callMethod('request', [
          js.JsObject.jsify({
            'method': 'eth_sendTransaction',
            'params': [transactionParams]
          })
        ])
      );

      return txHash;
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
      final chainId = await promiseToFuture(
        ethereum.callMethod('request', [
          js.JsObject.jsify({'method': 'eth_chainId'})
        ])
      );
      
      return chainId;
    } catch (e) {
      print('Error getting chain ID: $e');
      return null;
    }
  }

  static void onAccountsChanged(Function(List<String>) callback) {
    if (!isMetaMaskAvailable) return;

    final ethereum = js.context['ethereum'];
    ethereum.callMethod('on', ['accountsChanged', js.allowInterop((accounts) {
      callback(List<String>.from(accounts));
    })]);
  }

  static void onChainChanged(Function(String) callback) {
    if (!isMetaMaskAvailable) return;

    final ethereum = js.context['ethereum'];
    ethereum.callMethod('on', ['chainChanged', js.allowInterop((chainId) {
      callback(chainId);
    })]);
  }
}

