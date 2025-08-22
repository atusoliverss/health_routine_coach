// lib/models/user.dart

/// Representa a estrutura de dados de um usuário (AppUser para evitar conflito com firebase_auth.User).
/// Este modelo é mais para referência, pois os dados são lidos diretamente do Firestore.
class AppUser {
  // --- PROPRIEDADES ---
  final String id; // ID único do usuário (o mesmo do Firebase Auth).
  final String name; // Nome do usuário.
  final String email; // E-mail do usuário.

  // --- CONSTRUTOR ---
  AppUser({required this.id, required this.name, required this.email});
}
