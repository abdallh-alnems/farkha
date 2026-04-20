const sampleCycleJson = {
  'id': '1',
  'owner_id': 'test-uid',
  'name': 'دورة اختبارية',
  'start_date': '2026-01-01T00:00:00Z', // ISO 8601
  'start_date_raw': '2026-01-01T00:00:00Z',
  'bird_count': 1000,
  'chick_count': 1000,
  'space': '100',
  'breed': 'تسمين',
  'system_type': 'أرضي',
  'status': 'active',
  'role': 'owner',
  'mortality': '0',
  'total_expenses': '0',
  'total_sales': '0',
  'total_feed': '0',
  'average_weight': '0',
  'members': [
    {'user_id': 'uid-1', 'role': 'employee', 'name': 'مستخدم 1'},
  ],
};

const sampleLoginSuccessJson = {
  'status': 'success',
  'success': true,
  'token': 'fake-jwt-token',
  'user': {'id': 'test-uid', 'email': 'test@farkha.app', 'name': 'مستخدم اختبار'},
};

const sampleServerErrorJson = {
  'status': 'failure',
  'message': 'حدث خطأ في الخادم',
};

const sampleMemberJson = {
  'user_id': 'uid-2',
  'role': 'employee',
  'name': 'عضو جديد',
  'phone': '0501234567',
};

const sampleExpenseJson = {
  'id': '1',
  'label': 'العلف',
  'value': '500',
  'entry_date': '2026-01-15T10:00:00Z',
};

const sampleNoteJson = {
  'id': '1',
  'content': 'ملاحظة اختبارية',
  'entry_date': '2026-01-15T10:00:00Z',
};

const sampleSaleJson = {
  'id': '1',
  'quantity': '100',
  'total_weight': '200',
  'price_per_kg': '15',
  'total_price': '3000',
  'sale_date': '2026-01-20',
};

const sampleCustomDataJson = {
  'id': '1',
  'label': 'بيانات يومية',
  'value': '一切 طبيعي',
  'entry_date': '2026-01-15T10:00:00Z',
};
