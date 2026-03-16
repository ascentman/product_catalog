enum AppRoute {
  home('/', 'home'),
  productDetail('products/:id', 'productDetail'),
  showcase('/showcase', 'showcase');

  const AppRoute(this.path, this.name);
  final String path;
  final String name;

  /// Full path used for context.go / context.push.
  /// For productDetail pass [id].
  String location([int? id]) {
    switch (this) {
      case AppRoute.productDetail:
        assert(id != null);
        return '/products/$id';
      default:
        return path;
    }
  }
}
