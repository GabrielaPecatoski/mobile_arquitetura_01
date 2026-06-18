import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_problematico_catalog/domain/models/product.dart';
import 'package:flutter_problematico_catalog/presentation/viewmodels/favorites_viewmodel.dart';

Product _product(int id, {String title = 'Produto'}) => Product(
      id: id,
      title: title,
      description: 'desc',
      category: 'cat',
      price: 9.99,
      rating: 4.5,
      thumbnail: 'http://img/$id.png',
      images: ['http://img/$id.png'],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<FavoritesViewModel> buildViewModel() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesViewModel(prefs);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('começa vazio', () async {
    final vm = await buildViewModel();
    expect(vm.count, 0);
    expect(vm.favorites, isEmpty);
    expect(vm.isFavorite(1), isFalse);
  });

  test('toggle adiciona um produto aos favoritos', () async {
    final vm = await buildViewModel();
    vm.toggle(_product(1));

    expect(vm.count, 1);
    expect(vm.isFavorite(1), isTrue);
    expect(vm.favorites.single.id, 1);
  });

  test('toggle no mesmo produto remove dos favoritos', () async {
    final vm = await buildViewModel();
    vm.toggle(_product(1));
    vm.toggle(_product(1));

    expect(vm.count, 0);
    expect(vm.isFavorite(1), isFalse);
  });

  test('não duplica o mesmo id', () async {
    final vm = await buildViewModel();
    vm.toggle(_product(1, title: 'A'));
    vm.toggle(_product(1, title: 'B'));
    vm.toggle(_product(1, title: 'C'));

    expect(vm.count, 1);
    expect(vm.isFavorite(1), isTrue);
  });

  test('remove apaga o produto e ignora id inexistente', () async {
    final vm = await buildViewModel();
    vm.toggle(_product(1));
    vm.toggle(_product(2));

    vm.remove(1);
    expect(vm.isFavorite(1), isFalse);
    expect(vm.isFavorite(2), isTrue);
    expect(vm.count, 1);

    vm.remove(999);
    expect(vm.count, 1);
  });

  test('notifyListeners é disparado ao marcar e remover', () async {
    final vm = await buildViewModel();
    var notifications = 0;
    vm.addListener(() => notifications++);

    vm.toggle(_product(1));
    vm.remove(1);

    expect(notifications, 2);
  });

  test('favoritos são persistidos e recarregados em uma nova instância',
      () async {
    final vm = await buildViewModel();
    vm.toggle(_product(1, title: 'Persistido'));
    vm.toggle(_product(2));

    await Future<void>.delayed(Duration.zero);

    final reloaded = await buildViewModel();
    expect(reloaded.count, 2);
    expect(reloaded.isFavorite(1), isTrue);
    expect(reloaded.isFavorite(2), isTrue);
    expect(
      reloaded.favorites.firstWhere((p) => p.id == 1).title,
      'Persistido',
    );
  });
}
