class HomeController {
  List<Map<String, String>> getDestinations() {
    return [
      {'name': 'Hà Nội', 'description': 'Thủ đô nghìn năm văn hiến'},
      {'name': 'Đà Nẵng', 'description': 'Thành phố đáng sống nhất Việt Nam'},
      {'name': 'TP. Hồ Chí Minh', 'description': 'Trung tâm kinh tế sôi động'},
    ];
  }
}