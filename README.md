# K-ticket

## Introduce
> This is ticketing dapp which is ensure trust trade. 

## pre-condition
+ solidity ^0.8.3
+ ganache
+ flutter

## how to start
1. Start local ethereum
> Run ganache

2. Smart contract compile, migration
> truffle compile
> truffle migration

3. Set private key
> copy a private address in ganache you want and paste that in /ticketing_dapp/lib/controller/contract_linking.dart 11 line _privateKey
4. Run flutter
> flutter run at console ./ticketing_dapp or press the start button at ./ticketing_dapp (ex. Android Studio)
