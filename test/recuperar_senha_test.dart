import 'package:flutter_test/flutter_test.dart';

// Funções simuladas de validação
String? validateEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) return 'E-mail inválido';
  if (email == 'fake@teste.com') return 'E-mail não encontrado';
  return null;
}

String? validatePhone(String phone) {
  final phoneRegex = RegExp(r'^\+\d{2}\s\d{2}\s9\d{8}$');
  if (!phoneRegex.hasMatch(phone)) return 'Telefone inválido';
  return null;
}

String? validateToken(String token) {
  return (token != 'token123') ? 'Token inválido ou expirado' : null;
}

String? validatePassword(String password) {
  return password.length < 6 ? 'A senha deve ter no mínimo 6 dígitos' : null;
}

void main() {
  group('Recuperação de Senha - REC-SENHA-001', () {
    test('TC-001 - Dados válidos', () {
      final email = 'user@email.com';
      final phone = '+55 11 912345678';
      final token = 'token123';
      final senha = 'novaSenha123';

      expect(validateEmail(email), isNull);
      expect(validatePhone(phone), isNull);
      expect(validateToken(token), isNull);
      expect(validatePassword(senha), isNull);
    });

    test('TC-002 - E-mail inválido', () {
      final email = 'useremail.com';
      expect(validateEmail(email), 'E-mail inválido');
    });

    test('TC-003 - E-mail não cadastrado', () {
      final email = 'fake@teste.com';
      expect(validateEmail(email), 'E-mail não encontrado');
    });

    test('TC-004 - Telefone em formato inválido', () {
      final phone = '123456';
      expect(validatePhone(phone), 'Telefone inválido');
    });

    test('TC-005 - Token incorreto', () {
      final token = 'token_errado';
      expect(validateToken(token), 'Token inválido ou expirado');
    });

    test('TC-006 - Nova senha muito curta', () {
      final senha = '123';
      expect(validatePassword(senha), 'A senha deve ter no mínimo 6 dígitos');
    });
  });
}
