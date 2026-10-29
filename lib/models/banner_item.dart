class BannerItem {
  int id = 0;
  String? title;
  String image = '';

  /// product | category | none
  String linkType = 'none';
  int? linkId;

  BannerItem({
    this.id = 0,
    this.title,
    this.image = '',
    this.linkType = 'none',
    this.linkId,
  });

  BannerItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'] ?? '';
    linkType = json['link_type'] ?? 'none';
    linkId = json['link_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['link_type'] = linkType;
    data['link_id'] = linkId;
    return data;
  }
}
