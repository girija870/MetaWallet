# Flutter Wallet App with MetaMask Integration

A Flutter web application that integrates with MetaMask for sending Ethereum transactions. Users can connect their MetaMask wallet, send transactions, and receive transaction hashes.

## Features

- 🦊 **MetaMask Integration**: Seamless connection with MetaMask browser extension
- 💰 **Wallet Connection**: Connect and display wallet address with copy functionality
- 📤 **Send Transactions**: Send ETH with optional data field
- 🔗 **Transaction Tracking**: Receive and display transaction hashes
- 📱 **Responsive Design**: Clean Material Design interface
- ⚡ **Real-time Updates**: Listen for account and network changes

## Prerequisites

- Flutter SDK (3.22.2 or later)
- MetaMask browser extension
- Web browser with JavaScript enabled

## Installation

1. **Clone or download the project**
   ```bash
   cd wallet_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
   ```

4. **Open in browser**
   Navigate to `http://localhost:8080`

## Usage

### 1. Connect MetaMask Wallet
- Ensure MetaMask extension is installed and unlocked
- Click "Connect MetaMask" button
- Approve the connection in MetaMask popup
- Your wallet address will be displayed

### 2. Send Transaction
- Fill in the recipient address (0x...)
- Enter the amount in ETH (e.g., 0.001)
- Optionally add transaction data
- Click "Send Transaction"
- Confirm the transaction in MetaMask
- Transaction hash will be displayed upon success

### 3. Transaction Flow
```
User clicks "Send" → MetaMask opens → User confirms tx → Tx hash received
```

## Project Structure

```
wallet_app/
├── lib/
│   ├── main.dart                 # Main application UI
│   └── services/
│       └── metamask_service.dart # MetaMask integration service
├── web/
│   └── index.html               # Web entry point
├── pubspec.yaml                 # Dependencies
├── README.md                    # This file
└── TESTING_RESULTS.md          # Testing documentation
```

## Key Dependencies

- `web3dart: ^2.7.3` - Ethereum blockchain interaction
- `js: ^0.6.7` - JavaScript interop for MetaMask
- `http: ^1.1.0` - HTTP client
- `url_launcher: ^6.1.14` - URL handling

## API Reference

### MetaMaskService

#### Methods

- `isMetaMaskAvailable` - Check if MetaMask is installed
- `connectWallet()` - Connect to MetaMask wallet
- `getCurrentAccount()` - Get current connected account
- `sendTransaction()` - Send Ethereum transaction
- `getChainId()` - Get current network chain ID
- `onAccountsChanged()` - Listen for account changes
- `onChainChanged()` - Listen for network changes

#### Example Usage

```dart
// Check MetaMask availability
if (MetaMaskService.isMetaMaskAvailable) {
  // Connect wallet
  String? account = await MetaMaskService.connectWallet();
  
  // Send transaction
  String txHash = await MetaMaskService.sendTransaction(
    to: '0x742d35Cc6634C0532925a3b8D4C9db96590b5',
    value: '0x16345785D8A0000', // 0.1 ETH in Wei
  );
}
```

## Error Handling

The app handles various error scenarios:
- MetaMask not installed
- User rejection of connection/transaction
- Network errors
- Invalid transaction parameters

## Security Considerations

- Never store private keys in the application
- All transactions are signed by MetaMask
- Validate all user inputs
- Use testnet for development and testing

## Testing

See `TESTING_RESULTS.md` for detailed testing information.

### Manual Testing Steps

1. Install MetaMask extension
2. Connect to test network (Sepolia recommended)
3. Get test ETH from faucet
4. Test wallet connection
5. Test transaction sending
6. Verify transaction hash reception

## Troubleshooting

### MetaMask Not Available
- Ensure MetaMask extension is installed
- Refresh the page
- Check browser console for errors

### Transaction Fails
- Check account balance
- Verify recipient address format
- Ensure correct network is selected
- Check gas fees

### Connection Issues
- Unlock MetaMask wallet
- Check network connectivity
- Clear browser cache

## Development

### Building for Production

```bash
flutter build web
```

### Running Tests

```bash
flutter test
```

## Browser Compatibility

- Chrome (recommended)
- Firefox
- Safari
- Edge

## License

This project is for educational and development purposes.

## Support

For issues and questions, please check the troubleshooting section or review the testing documentation.

