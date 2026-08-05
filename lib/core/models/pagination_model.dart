enum PaginationType { pageNumber, cursor }

class PaginationParams {
  final int page;
  final int limit;
  final String? cursor;
  final String? searchQuery;
  final PaginationType type;

  const PaginationParams({
    this.page = 1,
    this.limit = 10,
    this.cursor,
    this.searchQuery,
    this.type = PaginationType.pageNumber,
  });

  int get skip => (page - 1) * limit;

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'limit': limit,
    };

    if (type == PaginationType.pageNumber) {
      params['skip'] = skip;
    } else if (cursor != null) {
      params['cursor'] = cursor;
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['q'] = searchQuery;
    }

    return params;
  }

  PaginationParams next([String? nextCursor]) {
    return PaginationParams(
      page: page + 1,
      limit: limit,
      cursor: nextCursor ?? cursor,
      searchQuery: searchQuery,
      type: type,
    );
  }

  PaginationParams copyWith({
    int? page,
    int? limit,
    String? cursor,
    String? searchQuery,
    PaginationType? type,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      cursor: cursor ?? this.cursor,
      searchQuery: searchQuery ?? this.searchQuery,
      type: type ?? this.type,
    );
  }
}
