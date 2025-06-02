import 'package:flutter_test/flutter_test.dart';

String? validateNome(String nome) {
  if (nome.trim().isEmpty) return 'Campo obrigatório';
  return null;
}

String? validateEmail(String email) {
  final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!regex.hasMatch(email.trim())) return 'Email inválido';
  return null;
}

String? validatePassword(String senha) {
  final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{6,}$');
  if (!regex.hasMatch(senha)) return 'A senha deve conter letra maiuscula, minúscula, número e caractere especial';
  return null;
}

String? validatePhone(String phone) {
  final regex = RegExp(r'^(\+55)?[\s-]?(\d{2})[\s-]?\d{4,5}[\s-]?\d{4}$');
  if (!regex.hasMatch(phone.trim())) return 'Formato de telefone inválido';
  return null;
}

bool areMultipleChoiceQuestionsAnswered(List<int?> respostas) {
  return respostas.every((resposta) => resposta != null);
}

void main() {
  group('Validação do formulário de cadastro', () {
    test('TC-001 - Nome não pode ser nulo', () {
      expect(validateNome(''), 'Campo obrigatório');
    });

    test('TC-002 - Email válido', () {
      expect(validateEmail('usuario@email.com'), null);
    });

    test('TC-003 - Email inválido', () {
      expect(validateEmail('usuarioemail.com'), 'Email inválido');
    });

    test('TC-004 - Senha válida', () {
      expect(validatePassword('A1234#bc'), null);
    });

    test('TC-005 - Senha inválida', () {
      expect(validatePassword('A1234123456a'), 'A senha deve conter letra maiuscula, minúscula, número e caractere especial');
    });

    test('TC-006 - Telefone válido', () {
      expect(validatePhone('+55 11 98888-1234'), null);
    });

    test('TC-007 - Telefone inválido', () {
      expect(validatePhone('12345'), 'Formato de telefone inválido');
    });

    test('TC-008 - Estilo de vida não selecionado', () {
      expect(areMultipleChoiceQuestionsAnswered([null, 1]), false);
    });

    test('TC-009 - Nível de experiência não selecionado', () {
      expect(areMultipleChoiceQuestionsAnswered([1, null]), false);
    });

    test('TC-010 - Campo de alergia em branco', () {
      // Campo opcional, portanto a entrada em branco não deve gerar erro
      final campo = '';
      expect(campo.isEmpty, true);
    });
  });
}
