String gerarImagemUnsplash(String termo) {
  return 'https://source.unsplash.com/600x400/?${Uri.encodeComponent(termo)}';
}