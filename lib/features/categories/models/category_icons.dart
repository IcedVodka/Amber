import 'package:flutter/material.dart';

enum CategoryIconGroup {
  daily('日常'),
  workStudy('学习'),
  leisure('娱乐'),
  sports('运动'),
  transport('交通'),
  social('社交');

  const CategoryIconGroup(this.label);

  final String label;

  static final Map<CategoryIconGroup, List<CategoryIcon>> _iconsByGroup = {
    for (final group in CategoryIconGroup.values)
      group: CategoryIcon.values
          .where((icon) => icon.group == group)
          .toList(growable: false),
  };

  List<CategoryIcon> get icons => _iconsByGroup[this] ?? const <CategoryIcon>[];
}

enum CategoryIcon {
  sleep('sleep', Icons.bedtime_rounded, '睡眠', CategoryIconGroup.daily),
  sun('sun', Icons.wb_sunny_rounded, '晨光', CategoryIconGroup.daily),
  night('night', Icons.nights_stay_rounded, '夜晚', CategoryIconGroup.daily),
  relax('relax', Icons.spa_rounded, '放松', CategoryIconGroup.daily),
  meditation(
    'meditation',
    Icons.self_improvement_rounded,
    '冥想',
    CategoryIconGroup.sports,
  ),
  home('home', Icons.home_rounded, '家', CategoryIconGroup.daily),
  sofa('sofa', Icons.weekend_rounded, '沙发', CategoryIconGroup.daily),
  pet('pet', Icons.pets_rounded, '宠物', CategoryIconGroup.daily),
  flower('flower', Icons.local_florist_rounded, '花园', CategoryIconGroup.daily),
  phone('phone', Icons.phone_iphone_rounded, '手机', CategoryIconGroup.social),
  watch('watch', Icons.watch_rounded, '手表', CategoryIconGroup.daily),
  keyboard(
    'keyboard',
    Icons.keyboard_rounded,
    '键盘',
    CategoryIconGroup.workStudy,
  ),
  mouse('mouse', Icons.mouse_rounded, '鼠标', CategoryIconGroup.workStudy),
  lightbulb(
    'lightbulb',
    Icons.lightbulb_rounded,
    '灯泡',
    CategoryIconGroup.workStudy,
  ),
  tools('tools', Icons.build_rounded, '工具', CategoryIconGroup.workStudy),
  key('key', Icons.key_rounded, '钥匙', CategoryIconGroup.daily),
  backpack(
    'backpack',
    Icons.backpack_rounded,
    '背包',
    CategoryIconGroup.transport,
  ),
  flashlight(
    'flashlight',
    Icons.flashlight_on_rounded,
    '手电',
    CategoryIconGroup.daily,
  ),
  cleaning(
    'cleaning',
    Icons.cleaning_services_rounded,
    '清洁',
    CategoryIconGroup.daily,
  ),
  laundry(
    'laundry',
    Icons.local_laundry_service_rounded,
    '洗衣',
    CategoryIconGroup.daily,
  ),
  kitchen('kitchen', Icons.kitchen_rounded, '厨房', CategoryIconGroup.daily),
  soap('soap', Icons.soap_rounded, '洗护', CategoryIconGroup.daily),
  shoppingCart(
    'shopping_cart',
    Icons.shopping_cart_rounded,
    '购物车',
    CategoryIconGroup.daily,
  ),
  shoppingBag(
    'shopping_bag',
    Icons.shopping_bag_rounded,
    '购物袋',
    CategoryIconGroup.daily,
  ),
  mall('mall', Icons.local_mall_rounded, '商场', CategoryIconGroup.daily),
  checkroom(
    'checkroom',
    Icons.checkroom_rounded,
    '衣物',
    CategoryIconGroup.daily,
  ),
  storage(
    'storage',
    Icons.inventory_2_rounded,
    '收纳',
    CategoryIconGroup.daily,
  ),
  wifi('wifi', Icons.wifi_rounded, '上网', CategoryIconGroup.social),
  heart('heart', Icons.favorite_rounded, '爱心', CategoryIconGroup.social),
  health(
    'health',
    Icons.health_and_safety_rounded,
    '健康',
    CategoryIconGroup.sports,
  ),
  medical(
    'medical',
    Icons.medical_services_rounded,
    '医疗',
    CategoryIconGroup.sports,
  ),
  hospital(
    'hospital',
    Icons.local_hospital_rounded,
    '医院',
    CategoryIconGroup.sports,
  ),
  medication(
    'medication',
    Icons.medication_rounded,
    '用药',
    CategoryIconGroup.sports,
  ),
  vaccines(
    'vaccines',
    Icons.vaccines_rounded,
    '疫苗',
    CategoryIconGroup.sports,
  ),
  blood(
    'blood',
    Icons.bloodtype_rounded,
    '血型',
    CategoryIconGroup.sports,
  ),
  healing(
    'healing',
    Icons.healing_rounded,
    '护理',
    CategoryIconGroup.sports,
  ),
  monitor(
    'monitor',
    Icons.monitor_heart_rounded,
    '心率',
    CategoryIconGroup.sports,
  ),
  briefcase(
    'briefcase',
    Icons.work_rounded,
    '工作',
    CategoryIconGroup.workStudy,
  ),
  office(
    'office',
    Icons.business_center_rounded,
    '办公',
    CategoryIconGroup.workStudy,
  ),
  laptop(
    'laptop',
    Icons.laptop_mac_rounded,
    '电脑',
    CategoryIconGroup.workStudy,
  ),
  desktop(
    'desktop',
    Icons.desktop_windows_rounded,
    '桌面',
    CategoryIconGroup.workStudy,
  ),
  calendar(
    'calendar',
    Icons.event_note_rounded,
    '日程',
    CategoryIconGroup.workStudy,
  ),
  assignment(
    'assignment',
    Icons.assignment_rounded,
    '任务',
    CategoryIconGroup.workStudy,
  ),
  analytics(
    'analytics',
    Icons.analytics_rounded,
    '分析',
    CategoryIconGroup.workStudy,
  ),
  collaboration(
    'collaboration',
    Icons.handshake_rounded,
    '协作',
    CategoryIconGroup.social,
  ),
  engineering(
    'engineering',
    Icons.engineering_rounded,
    '工程',
    CategoryIconGroup.workStudy,
  ),
  study(
    'study',
    Icons.menu_book_rounded,
    '学习',
    CategoryIconGroup.workStudy,
  ),
  school(
    'school',
    Icons.school_rounded,
    '学校',
    CategoryIconGroup.workStudy,
  ),
  stories(
    'stories',
    Icons.auto_stories_rounded,
    '阅读',
    CategoryIconGroup.workStudy,
  ),
  calculate(
    'calculate',
    Icons.calculate_rounded,
    '数学',
    CategoryIconGroup.workStudy,
  ),
  science(
    'science',
    Icons.science_rounded,
    '实验',
    CategoryIconGroup.workStudy,
  ),
  psychology(
    'psychology',
    Icons.psychology_rounded,
    '思考',
    CategoryIconGroup.workStudy,
  ),
  biotech(
    'biotech',
    Icons.biotech_rounded,
    '生物',
    CategoryIconGroup.workStudy,
  ),
  language(
    'language',
    Icons.language_rounded,
    '语言',
    CategoryIconGroup.social,
  ),
  quiz('quiz', Icons.quiz_rounded, '测验', CategoryIconGroup.workStudy),
  movie('movie', Icons.movie_rounded, '电影', CategoryIconGroup.leisure),
  theater('theater', Icons.theaters_rounded, '影院', CategoryIconGroup.leisure),
  music('music', Icons.music_note_rounded, '音乐', CategoryIconGroup.leisure),
  headphones(
    'headphones',
    Icons.headphones_rounded,
    '听歌',
    CategoryIconGroup.leisure,
  ),
  mic('mic', Icons.mic_rounded, 'K歌', CategoryIconGroup.leisure),
  creative(
    'creative',
    Icons.palette_rounded,
    '创作',
    CategoryIconGroup.leisure,
  ),
  brush('brush', Icons.brush_rounded, '手作', CategoryIconGroup.leisure),
  camera(
    'camera',
    Icons.camera_alt_rounded,
    '摄影',
    CategoryIconGroup.leisure,
  ),
  tv('tv', Icons.tv_rounded, '电视', CategoryIconGroup.leisure),
  game(
    'game',
    Icons.sports_esports_rounded,
    '游戏',
    CategoryIconGroup.leisure,
  ),
  video(
    'video',
    Icons.video_library_rounded,
    '影音',
    CategoryIconGroup.leisure,
  ),
  luggage(
    'luggage',
    Icons.luggage_rounded,
    '行李',
    CategoryIconGroup.transport,
  ),
  hotel('hotel', Icons.hotel_rounded, '酒店', CategoryIconGroup.transport),
  map('map', Icons.map_rounded, '地图', CategoryIconGroup.transport),
  explore(
    'explore',
    Icons.explore_rounded,
    '探索',
    CategoryIconGroup.transport,
  ),
  beach(
    'beach',
    Icons.beach_access_rounded,
    '海滩',
    CategoryIconGroup.transport,
  ),
  museum(
    'museum',
    Icons.museum_rounded,
    '博物馆',
    CategoryIconGroup.leisure,
  ),
  public('public', Icons.public_rounded, '地球', CategoryIconGroup.transport),
  terrain(
    'terrain',
    Icons.terrain_rounded,
    '山地',
    CategoryIconGroup.transport,
  ),
  attractions(
    'attractions',
    Icons.attractions_rounded,
    '景点',
    CategoryIconGroup.transport,
  ),
  coffee(
    'coffee',
    Icons.local_cafe_rounded,
    '咖啡',
    CategoryIconGroup.social,
  ),
  restaurant(
    'restaurant',
    Icons.restaurant_rounded,
    '用餐',
    CategoryIconGroup.social,
  ),
  fastfood(
    'fastfood',
    Icons.fastfood_rounded,
    '快餐',
    CategoryIconGroup.leisure,
  ),
  pizza(
    'pizza',
    Icons.local_pizza_rounded,
    '披萨',
    CategoryIconGroup.leisure,
  ),
  icecream(
    'icecream',
    Icons.icecream_rounded,
    '冰淇淋',
    CategoryIconGroup.leisure,
  ),
  cake('cake', Icons.cake_rounded, '甜点', CategoryIconGroup.leisure),
  drink(
    'drink',
    Icons.local_drink_rounded,
    '饮品',
    CategoryIconGroup.social,
  ),
  bar('bar', Icons.local_bar_rounded, '酒吧', CategoryIconGroup.social),
  ramen(
    'ramen',
    Icons.ramen_dining_rounded,
    '拉面',
    CategoryIconGroup.leisure,
  ),
  fitness(
    'fitness',
    Icons.fitness_center_rounded,
    '健身',
    CategoryIconGroup.sports,
  ),
  soccer(
    'soccer',
    Icons.sports_soccer_rounded,
    '足球',
    CategoryIconGroup.sports,
  ),
  basketball(
    'basketball',
    Icons.sports_basketball_rounded,
    '篮球',
    CategoryIconGroup.sports,
  ),
  tennis(
    'tennis',
    Icons.sports_tennis_rounded,
    '网球',
    CategoryIconGroup.sports,
  ),
  volleyball(
    'volleyball',
    Icons.sports_volleyball_rounded,
    '排球',
    CategoryIconGroup.sports,
  ),
  handball(
    'handball',
    Icons.sports_handball_rounded,
    '手球',
    CategoryIconGroup.sports,
  ),
  running(
    'running',
    Icons.directions_run_rounded,
    '跑步',
    CategoryIconGroup.sports,
  ),
  hiking(
    'hiking',
    Icons.hiking_rounded,
    '徒步',
    CategoryIconGroup.sports,
  ),
  swim('swim', Icons.pool_rounded, '游泳', CategoryIconGroup.sports),
  car('car', Icons.directions_car_rounded, '汽车', CategoryIconGroup.transport),
  bus('bus', Icons.directions_bus_rounded, '公交', CategoryIconGroup.transport),
  subway(
    'subway',
    Icons.directions_subway_rounded,
    '地铁',
    CategoryIconGroup.transport,
  ),
  train(
    'train',
    Icons.train_rounded,
    '火车',
    CategoryIconGroup.transport,
  ),
  flight(
    'flight',
    Icons.flight_rounded,
    '飞机',
    CategoryIconGroup.transport,
  ),
  bike(
    'bike',
    Icons.directions_bike_rounded,
    '自行车',
    CategoryIconGroup.transport,
  ),
  motor(
    'motor',
    Icons.two_wheeler_rounded,
    '摩托',
    CategoryIconGroup.transport,
  ),
  taxi(
    'taxi',
    Icons.local_taxi_rounded,
    '出租',
    CategoryIconGroup.transport,
  ),
  scooter(
    'scooter',
    Icons.electric_scooter_rounded,
    '电动',
    CategoryIconGroup.transport,
  ),
  commute(
    'commute',
    Icons.commute_rounded,
    '通勤',
    CategoryIconGroup.transport,
  ),
  chat('chat', Icons.chat_rounded, '聊天', CategoryIconGroup.social),
  forum('forum', Icons.forum_rounded, '论坛', CategoryIconGroup.social),
  people('people', Icons.people_rounded, '好友', CategoryIconGroup.social),
  groups('groups', Icons.groups_rounded, '群组', CategoryIconGroup.social),
  share('share', Icons.share_rounded, '分享', CategoryIconGroup.social),
  thumb('thumb', Icons.thumb_up_rounded, '点赞', CategoryIconGroup.social),
  emoji('emoji', Icons.emoji_emotions_rounded, '表情', CategoryIconGroup.social),
  call('call', Icons.call_rounded, '通话', CategoryIconGroup.social),
  videoCall(
    'video_call',
    Icons.videocam_rounded,
    '视频',
    CategoryIconGroup.social,
  );

  const CategoryIcon(this.code, this.icon, this.label, this.group);

  final String code;
  final IconData icon;
  final String label;
  final CategoryIconGroup group;

  static final CategoryIcon _fallback = CategoryIcon.values.first;
  static final Map<String, CategoryIcon> _byCode = {
    for (final icon in CategoryIcon.values) icon.code: icon,
  };

  static CategoryIcon fromCode(String? code) {
    if (code == null) {
      return _fallback;
    }
    return _byCode[code] ?? _fallback;
  }

  static IconData iconByCode(String? code) {
    return fromCode(code).icon;
  }
}
