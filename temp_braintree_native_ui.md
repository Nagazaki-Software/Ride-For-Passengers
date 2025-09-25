# braintree_native_ui

Plugin Flutter que integra o SDK oficial da Braintree para permitir a
implementa????o de fluxos de pagamento com UI pr??pria. Ele tokeniza cart??es,
executa verifica????es 3???D Secure (3DS2) e coleta *device data* para preven????o
contra fraudes sem utilizar o componente Drop-in.

## Recursos

- Tokeniza????o de cart??o de cr??dito
- Verifica????o 3???D Secure 2
- Coleta de dados do dispositivo
- API simples em Dart utilizando *Method Channels*
- Pagamentos via Google Pay e Apple Pay
- Preparado para integra????o com Google Pay e Apple Pay

## Instala????o

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  braintree_native_ui: ^0.2.0
```

No iOS execute `pod install` ap??s atualizar as depend??ncias.

## Uso

```dart
final braintree = BraintreeNativeUi();

final nonce = await braintree.tokenizeCard(
  authorization: '<TOKENIZATION_KEY_OR_CLIENT_TOKEN>',
  number: '4111111111111111',
  expirationMonth: '12',
  expirationYear: '2030',
  cvv: '123',
);

final verifiedNonce = await braintree.performThreeDSecure(
  authorization: '<TOKENIZATION_KEY_OR_CLIENT_TOKEN>',
  nonce: nonce!,
  amount: '10.00',
  email: 'user@example.com',
  billingAddress: {
    'streetAddress': 'Rua 1',
    'locality': 'Sao Paulo',
    'region': 'SP',
    'postalCode': '01000-000',
    'countryCodeAlpha2': 'BR',
  },
);

final deviceData = await braintree.collectDeviceData(
  authorization: '<TOKENIZATION_KEY_OR_CLIENT_TOKEN>',
  forCard: true,
);
```

### Capturando dados com TextFields

```dart
final numberController = TextEditingController();
final expMonthController = TextEditingController();
final expYearController = TextEditingController();
final cvvController = TextEditingController();

// Campos de entrada personalizados
TextField(controller: numberController);
TextField(controller: expMonthController);
TextField(controller: expYearController);
TextField(controller: cvvController);

final nonce = await braintree.tokenizeCard(
  authorization: '<TOKENIZATION_KEY_OR_CLIENT_TOKEN>',
  number: numberController.text,
  expirationMonth: expMonthController.text,
  expirationYear: expYearController.text,
  cvv: cvvController.text,
);
```

## Google Pay

Exemplo de solicita????o de pagamento com Google Pay:

```dart
final googlePayNonce = await braintree.requestGooglePayPayment(
  authorization: '<TOKENIZATION_KEY_OR_CLIENT_TOKEN>',
  amount: '10.00',
  currencyCode: 'USD',
);
```

Configure o `gatewayMerchantId` e o ambiente (`TEST` ou `PRODUCTION`) conforme a documenta????o do Google Pay antes de enviar para produ????o.

## Apple Pay

Solicitando pagamento via Apple Pay:

```dart
final applePayNonce = await braintree.requestApplePayPayment(
  authorization: '<TOKENIZATION_KEY_OR_CLIENT_TOKEN>',
  merchantIdentifier: 'merchant.com.exemplo',
  countryCode: 'US',
  currencyCode: 'USD',
  amount: '10.00',
);
```

Certifique-se de registrar o `merchantIdentifier` e definir o ambiente apropriado (`sandbox` ou produ????o) no Apple Developer.

Veja o diret??rio [`example/`](example) para um aplicativo completo.

## Desenvolvimento

Execute os testes com:

```bash
flutter test
```

## Licen??a

Distribu??do sob a licen??a MIT. Veja `LICENSE` para mais informa????es.

## Sobre

Um plugin brasileiro.
Lucas C??sar Lopes

