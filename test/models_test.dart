import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_problematico_catalog/domain/models/product.dart';
import 'package:flutter_problematico_catalog/models/user.dart';

void main() {
  group('Product.fromMap (formato DummyJSON)', () {
    test('mapeia os campos a partir do JSON da API', () {
      final map = {
        'id': 1,
        'title': 'iPhone 9',
        'description': 'An apple mobile',
        'category': 'smartphones',
        'price': 549.0,
        'discountPercentage': 12.96,
        'rating': 4.69,
        'stock': 94,
        'brand': 'Apple',
        'thumbnail': 'https://i.dummyjson.com/thumb.jpg',
        'images': ['https://i.dummyjson.com/1.jpg', 'https://i.dummyjson.com/2.jpg'],
      };

      final product = Product.fromMap(map);

      expect(product.id, 1);
      expect(product.title, 'iPhone 9');
      expect(product.price, 549.0);
      expect(product.rating, 4.69);
      expect(product.images, hasLength(2));
      expect(product.thumbnail, 'https://i.dummyjson.com/thumb.jpg');
    });

    test('usa valores padrão quando campos estão ausentes ou nulos', () {
      final product = Product.fromMap({'id': 5, 'title': 'Mínimo'});

      expect(product.id, 5);
      expect(product.title, 'Mínimo');
      expect(product.price, 0.0);
      expect(product.rating, 0.0);
      expect(product.images, isEmpty);
      expect(product.brand, '');
    });

    test('converte price inteiro para double', () {
      final product = Product.fromMap({'id': 1, 'title': 'X', 'price': 10});
      expect(product.price, isA<double>());
      expect(product.price, 10.0);
    });

    test('toMap/fromMap é um round-trip consistente', () {
      final original = Product.fromMap({
        'id': 7,
        'title': 'Round',
        'description': 'd',
        'category': 'c',
        'price': 1.5,
        'rating': 3.0,
        'thumbnail': 't',
        'images': ['a', 'b'],
      });

      final restored = Product.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.price, original.price);
      expect(restored.images, original.images);
    });

    test('copyWith altera apenas os campos informados', () {
      final original = Product.fromMap({
        'id': 0,
        'title': 'Antigo',
        'price': 10.0,
        'thumbnail': 't',
        'rating': 4.0,
      });

      final updated = original.copyWith(id: 195, title: 'Novo');

      expect(updated.id, 195);
      expect(updated.title, 'Novo');
      expect(updated.price, original.price);
      expect(updated.rating, original.rating);
    });
  });

  group('User.fromMap (resposta de /auth/login)', () {
    test('lê accessToken como token', () {
      final user = User.fromMap({
        'id': 1,
        'username': 'emilys',
        'email': 'emily@x.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'image': 'https://img/emily.png',
        'accessToken': 'abc123',
        'refreshToken': 'ref456',
      });

      expect(user.username, 'emilys');
      expect(user.token, 'abc123');
      expect(user.refreshToken, 'ref456');
    });

    test('token vazio quando accessToken ausente', () {
      final user = User.fromMap({
        'id': 1,
        'username': 'emilys',
        'email': 'emily@x.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'image': 'https://img/emily.png',
      });

      expect(user.token, '');
      expect(user.refreshToken, '');
    });

    test('toMap preserva o token sob a chave accessToken', () {
      final user = User.fromMap({
        'id': 1,
        'username': 'emilys',
        'email': 'emily@x.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'image': 'https://img/emily.png',
        'accessToken': 'tok',
      });

      final map = user.toMap();
      expect(map['accessToken'], 'tok');

      final restored = User.fromMap(map);
      expect(restored.token, 'tok');
    });
  });
}
