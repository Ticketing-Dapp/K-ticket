import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcUrl = "HTTP://10.0.2.2:7545";
  final String _wsUrl = "ws://10.0.2.2:7545/";
  final String _privateKey = "8a90e3e554536211032390f57dc3354770cd88d182a9a674a29b5dce491a2649";

  bool checkMyTicketBool = false;
  // _client variable will be used to establish a connection to the ethereum rpc node with the help of WebSocket.
  // isLoading variable will be used to check the state of the contract.
  late Web3Client _client;
  bool isLoading = true;

  // _abiCode variable will be used to, read the contract abi.
  // _contractAddress variable will be used to store the contract address of the deployed smart contract.
  late String _abiCode;
  late EthereumAddress _contractAddress;

  // _credentials variable will store the credentials of the smart contract deployer.
  late Credentials _credentials;

  // _contract variable will be used to tell Web3dart where our contract is declared.
  // _yourName and _setName variable will be used to store the functions declared in our HelloWorld.sol smart contract.
  late DeployedContract _contract;

  late ContractFunction _register;
  late ContractFunction _buy;
  late ContractFunction _transfer;
  late ContractFunction _set;
  late ContractFunction _myTicket;

  ContractLinking() {
    initialSetup();
  }

  initialSetup() async {
    // establish a connection to the ethereum rpc node. The socketConnector
    // property allows more efficient event streams over websocket instead of
    // http-polls. However, the socketConnector property is experimental.
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {

    // Reading the contract abi
    String abiStringFile =
    await rootBundle.loadString("assets/src/artifacts/Sell.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);

    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    _credentials = await EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> getDeployedContract() async {

    // Telling Web3dart where our contract is declared.
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "Sell"), _contractAddress);

    // Extracting the functions, declared in contract.
    _register = _contract.function("registerConcert");
    _buy = _contract.function("buyTicket");
    _transfer = _contract.function("transferTicket");
    _set = _contract.function("setPrice");
    _myTicket = _contract.function("checkMyTicket");
  }

  registerConcert(BigInt concert, BigInt number, BigInt vipPrice, BigInt rPrice, BigInt aPrice) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract : _contract, function : _register, parameters: [concert, number, vipPrice, rPrice, aPrice]));
    isLoading = false;
    notifyListeners();
  }

  buyTicket(BigInt concert, BigInt number) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract : _contract, function : _buy, parameters: [concert, number]));
    isLoading = false;
    notifyListeners();
  }

  transferTicket(BigInt concert, BigInt number) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract : _contract, function : _transfer, parameters: [concert, number]));
    isLoading = false;
    notifyListeners();
  }

  setPrice(BigInt concert, BigInt number, BigInt price) async {
    isLoading = true;
    notifyListeners();
    await checkMyTicket(concert, number);

    if(checkMyTicketBool == true){
      await _client.sendTransaction(
          _credentials,
          Transaction.callContract(
              contract : _contract, function : _set, parameters: [concert, number, price]));
      isLoading = false;
      notifyListeners();
    } else if (checkMyTicketBool == false){
      print('don\'t trade');
    } else {
      print('error');
    }
  }

  Future<bool> checkMyTicket(BigInt concert, BigInt number) async {
    try {
      var infor = await _client.call(contract : _contract, function : _myTicket, params: [concert, number]);

      checkMyTicketBool = infor[0];
      notifyListeners();

      return Future.value(true);
    } catch (e) {
      print('error');
      print(e);
      checkMyTicketBool = false;
      return Future.value(false);
    }
  }
}