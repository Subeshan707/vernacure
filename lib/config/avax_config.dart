/// Avalanche Blockchain Configuration
library;

class AvaxConfig {
  // Fuji C-Chain Testnet Configuration
  static const String networkName = 'Avalanche Fuji C-Chain';
  static const String rpcUrl = 'https://api.avax-test.network/ext/bc/C/rpc';
  static const int chainId = 43113;
  static const String currencySymbol = 'AVAX';
  static const String blockExplorer = 'https://testnet.snowtrace.io';
  static const String faucetUrl = 'https://faucet.avax.network';
  
  // Smart Contract Address (update after deployment)
  static const String contractAddress = '0x0000000000000000000000000000000000000000';
  
  // Contract ABI (simplified for hackathon)
  static const String contractAbi = '''
  [
    {
      "inputs": [
        {"internalType": "string", "name": "_ipfsHash", "type": "string"},
        {"internalType": "string", "name": "_policyType", "type": "string"},
        {"internalType": "uint256", "name": "_coverage", "type": "uint256"}
      ],
      "name": "purchasePolicy",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "_policyId", "type": "uint256"}],
      "name": "getPolicy",
      "outputs": [
        {
          "components": [
            {"internalType": "uint256", "name": "policyId", "type": "uint256"},
            {"internalType": "address", "name": "owner", "type": "address"},
            {"internalType": "string", "name": "ipfsHash", "type": "string"},
            {"internalType": "string", "name": "policyType", "type": "string"},
            {"internalType": "uint256", "name": "premium", "type": "uint256"},
            {"internalType": "uint256", "name": "coverage", "type": "uint256"},
            {"internalType": "uint256", "name": "purchaseDate", "type": "uint256"},
            {"internalType": "bool", "name": "isActive", "type": "bool"}
          ],
          "internalType": "struct VernacureInsurance.Policy",
          "name": "",
          "type": "tuple"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "address", "name": "_user", "type": "address"}],
      "name": "getUserPolicies",
      "outputs": [{"internalType": "uint256[]", "name": "", "type": "uint256[]"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {"indexed": true, "internalType": "uint256", "name": "policyId", "type": "uint256"},
        {"indexed": false, "internalType": "address", "name": "owner", "type": "address"},
        {"indexed": false, "internalType": "string", "name": "ipfsHash", "type": "string"}
      ],
      "name": "PolicyPurchased",
      "type": "event"
    }
  ]
  ''';
}
