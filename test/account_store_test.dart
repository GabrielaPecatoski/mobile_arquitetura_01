import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_problematico_catalog/services/account_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('register cria a conta e retorna o usuário', () async {
    final user = await AccountStore.register(
      firstName: 'Maria',
      lastName: 'Silva',
      email: 'maria@x.com',
      username: 'maria',
      password: '1234',
    );

    expect(user.username, 'maria');
    expect(user.firstName, 'Maria');
    expect(user.token, isEmpty);
    expect(await AccountStore.usernameExists('maria'), isTrue);
  });

  test('authenticate valida usuário/senha de uma conta criada (offline)',
      () async {
    await AccountStore.register(
      firstName: 'Maria',
      lastName: 'Silva',
      email: 'maria@x.com',
      username: 'maria',
      password: '1234',
    );

    final ok = await AccountStore.authenticate('maria', '1234');
    expect(ok, isNotNull);
    expect(ok!.username, 'maria');

    final wrong = await AccountStore.authenticate('maria', 'errada');
    expect(wrong, isNull);
  });

  test('não permite cadastrar usuário duplicado', () async {
    await AccountStore.register(
      firstName: 'Maria',
      lastName: 'Silva',
      email: 'maria@x.com',
      username: 'maria',
      password: '1234',
    );

    expect(
      () => AccountStore.register(
        firstName: 'Outra',
        lastName: 'Pessoa',
        email: 'outra@x.com',
        username: 'MARIA',
        password: '5678',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('conta criada persiste entre instâncias (sobrevive ao reinício)',
      () async {
    await AccountStore.register(
      firstName: 'Joao',
      lastName: 'Souza',
      email: 'joao@x.com',
      username: 'joao',
      password: 'abcd',
    );

    final user = await AccountStore.authenticate('joao', 'abcd');
    expect(user, isNotNull);
    expect(user!.email, 'joao@x.com');
  });
}
