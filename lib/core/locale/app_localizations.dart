import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      // General
      'cancel': 'Hủy',
      'ok': 'Đồng ý',
      'close': 'Đóng',
      'confirm': 'Xác nhận',
      'yes': 'Có',
      'no': 'Không',
      'error': 'Lỗi',
      'success': 'Thành công',
      'warning': 'Cảnh báo',
      'search': 'Tìm kiếm',
      'empty': 'Trống',
      'loading': 'Đang tải...',
      'submit': 'Gửi',
      'save': 'Lưu',
      'delete': 'Xóa',
      'edit': 'Sửa',
      'create': 'Tạo mới',
      'add': 'Thêm',
      'remove': 'Xóa bỏ',
      'total': 'Tổng cộng',
      'subtotal': 'Tạm tính',
      'status': 'Trạng thái',
      'date': 'Ngày',
      'time': 'Thời gian',

      // Welcome/Splash
      'welcome_title': 'Chào mừng!',
      'welcome_subtitle': 'Chào mừng bạn đến với ứng dụng ONI Mobile POS',

      // Auth Screen
      'subdomain_label': 'Doanh nghiệp (Subdomain)',
      'subdomain_hint': 'ten-doanh-nghiep',
      'subdomain_error': 'Vui lòng nhập tên subdomain doanh nghiệp',
      'email_label': 'Tài khoản (Email)',
      'email_hint': 'email@example.com',
      'email_error': 'Vui lòng nhập email tài khoản',
      'password_label': 'Mật khẩu',
      'password_error': 'Vui lòng nhập mật khẩu',
      'sign_in_button': 'ĐĂNG NHẬP HỆ THỐNG',
      'sign_in_loading': 'Đang đăng nhập...',
      'sign_in_failed': 'Đăng nhập thất bại.',

      // Main Navigation
      'nav_sales': 'Bán tại quầy',
      'nav_products': 'Sản phẩm',
      'nav_transactions': 'Đơn hàng',
      'nav_account': 'Cài đặt',

      // Home/POS
      'search_products_hint': 'Tìm kiếm sản phẩm...',
      'select_customer': 'Chọn khách hàng',
      'no_customer': 'Khách lẻ',
      'add_customer': 'Thêm khách hàng',
      'empty_cart': 'Giỏ hàng trống',
      'empty_cart_subtitle': 'Chưa có sản phẩm nào trong giỏ hàng',
      'pay': 'Thanh toán',
      'add_discount': 'Thêm giảm giá',
      'discount': 'Giảm giá',
      'tax': 'Thuế',
      'payment_detail': 'Chi tiết thanh toán',
      'payment_success': 'Thanh toán thành công',
      'change_amount': 'Tiền thừa',
      'paid_amount': 'Khách thanh toán',
      'pay_now': 'Xác nhận thanh toán',
      'cash': 'Tiền mặt',
      'custom_payment': 'Khác',
      'receipt': 'Hóa đơn',
      'print_receipt': 'In hóa đơn',
      'share_receipt': 'Chia sẻ',
      'success_checkout': 'Giao dịch đã được hoàn thành!',
      'cannot_checkout_empty': 'Giỏ hàng trống, không thể thanh toán!',
      'transaction_amount': 'Tổng tiền hóa đơn',
      'change_returned': 'Tiền thối lại cho khách',

      // Shop Select
      'select_shop_title': 'Chọn cửa hàng',
      'select_shop_subtitle': 'Vui lòng chọn chi nhánh làm việc',
      'select_shop_button': 'Vào cửa hàng',
      'no_shop_found': 'Không tìm thấy chi nhánh nào.',

      // Products
      'categories': 'Danh mục',
      'all_categories': 'Tất cả',
      'create_product': 'Thêm sản phẩm',
      'edit_product': 'Chỉnh sửa sản phẩm',
      'product_name': 'Tên sản phẩm',
      'price': 'Giá bán',
      'cost_price': 'Giá vốn',
      'stock': 'Tồn kho',
      'sku': 'Mã SKU',
      'barcode': 'Mã vạch (Barcode)',
      'description': 'Mô tả',
      'select_category': 'Chọn danh mục',
      'save_product': 'Lưu sản phẩm',
      'delete_product': 'Xóa sản phẩm',
      'confirm_delete_product': 'Bạn có chắc chắn muốn xóa sản phẩm này không?',
      'name_required': 'Tên sản phẩm không được để trống',
      'price_required': 'Giá bán không được để trống',
      'cost_required': 'Giá vốn không được để trống',
      'stock_required': 'Tồn kho không được để trống',

      // Transactions
      'search_transactions': 'Tìm kiếm mã đơn hàng...',
      'transaction_detail': 'Chi tiết đơn hàng',
      'order_id': 'Mã đơn hàng',
      'cashier': 'Thu ngân',
      'customer': 'Khách hàng',
      'change': 'Tiền thừa',
      'method': 'Phương thức',
      'printed': 'Đã in',
      'retry_print': 'In lại hóa đơn',
      'items': 'sản phẩm',
      'payment_status': 'Trạng thái thanh toán',
      'success_status': 'Thành công',
      'failed_status': 'Thất bại',
      'refunded_status': 'Hoàn tiền',
      'empty_transactions': 'Chưa có đơn hàng',
      'empty_transactions_subtitle': 'Các đơn hàng đã bán sẽ xuất hiện ở đây',

      // Account/Settings
      'profile': 'Thông tin cá nhân',
      'theme': 'Giao diện',
      'printer_settings': 'Cấu hình máy in',
      'about': 'Giới thiệu',
      'language': 'Ngôn ngữ',
      'sign_out': 'Đăng xuất',
      'delete_account': 'Xóa tài khoản',
      'dark_mode': 'Chế độ tối',
      'about_title': 'Thông tin ứng dụng',
      'about_description': 'ONI Mobile POS là ứng dụng quản lý bán hàng cầm tay thuộc hệ sinh thái ONI ERP, giúp vận hành cửa hàng chuyên nghiệp, nhanh chóng và chính xác.',
      'language_title': 'Ngôn ngữ ứng dụng',
      'select_language': 'Chọn ngôn ngữ',
      'confirm_sign_out': 'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống không?',
      'confirm_delete_account': 'Xóa tài khoản',
      'confirm_delete_account_warn': 'Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản của mình? Hành động này không thể hoàn tác và tất cả dữ liệu POS trên thiết bị cũng như trên máy chủ sẽ bị xóa sạch.',
      'select_printer': 'Chọn máy in',
      'paper_size': 'Khổ giấy',
      'print_test': 'In thử',
      'out_of_stock': 'Hết hàng',
      'sold': 'Đã bán',
      'remove_all': 'Xóa toàn bộ',
      'remove_all_confirm': 'Bạn có chắc chắn muốn xóa tất cả sản phẩm khỏi giỏ hàng?',
      'remove_confirm': 'Bạn có chắc chắn muốn xóa sản phẩm này?',
      'products_label': 'sản phẩm',
      'pcs_label': 'món',
    },
    'en': {
      // General
      'cancel': 'Cancel',
      'ok': 'OK',
      'close': 'Close',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'search': 'Search',
      'empty': 'Empty',
      'loading': 'Loading...',
      'submit': 'Submit',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'create': 'Create',
      'add': 'Add',
      'remove': 'Remove',
      'total': 'Total',
      'subtotal': 'Subtotal',
      'status': 'Status',
      'date': 'Date',
      'time': 'Time',

      // Welcome/Splash
      'welcome_title': 'Welcome!',
      'welcome_subtitle': 'Welcome to ONI Mobile POS app',

      // Auth Screen
      'subdomain_label': 'Business (Subdomain)',
      'subdomain_hint': 'your-business',
      'subdomain_error': 'Please enter business subdomain',
      'email_label': 'Account (Email)',
      'email_hint': 'email@example.com',
      'email_error': 'Please enter email account',
      'password_label': 'Password',
      'password_error': 'Please enter password',
      'sign_in_button': 'SIGN IN TO SYSTEM',
      'sign_in_loading': 'Signing in...',
      'sign_in_failed': 'Sign in failed.',

      // Main Navigation
      'nav_sales': 'Register',
      'nav_products': 'Products',
      'nav_transactions': 'Orders',
      'nav_account': 'Settings',

      // Home/POS
      'search_products_hint': 'Search products...',
      'select_customer': 'Select Customer',
      'no_customer': 'General Guest',
      'add_customer': 'Add Customer',
      'empty_cart': 'Empty Cart',
      'empty_cart_subtitle': 'No products added to cart',
      'pay': 'Pay',
      'add_discount': 'Add Discount',
      'discount': 'Discount',
      'tax': 'Tax',
      'payment_detail': 'Payment Details',
      'payment_success': 'Payment Successful',
      'change_amount': 'Change',
      'paid_amount': 'Amount Paid',
      'pay_now': 'Confirm Payment',
      'cash': 'Cash',
      'custom_payment': 'Custom',
      'receipt': 'Receipt',
      'print_receipt': 'Print Receipt',
      'share_receipt': 'Share',
      'success_checkout': 'Transaction completed successfully!',
      'cannot_checkout_empty': 'Cart is empty, cannot checkout!',
      'transaction_amount': 'Invoice Amount',
      'change_returned': 'Change returned to guest',

      // Shop Select
      'select_shop_title': 'Select Shop',
      'select_shop_subtitle': 'Please select a branch to work with',
      'select_shop_button': 'Enter Shop',
      'no_shop_found': 'No branches found.',

      // Products
      'categories': 'Categories',
      'all_categories': 'All',
      'create_product': 'Add Product',
      'edit_product': 'Edit Product',
      'product_name': 'Product Name',
      'price': 'Selling Price',
      'cost_price': 'Cost Price',
      'stock': 'Stock',
      'sku': 'SKU Code',
      'barcode': 'Barcode',
      'description': 'Description',
      'select_category': 'Select Category',
      'save_product': 'Save Product',
      'delete_product': 'Delete Product',
      'confirm_delete_product': 'Are you sure you want to delete this product?',
      'name_required': 'Product name cannot be empty',
      'price_required': 'Price cannot be empty',
      'cost_required': 'Cost cannot be empty',
      'stock_required': 'Stock cannot be empty',

      // Transactions
      'search_transactions': 'Search order ID...',
      'transaction_detail': 'Order Detail',
      'order_id': 'Order ID',
      'cashier': 'Cashier',
      'customer': 'Customer',
      'change': 'Change',
      'method': 'Method',
      'printed': 'Printed',
      'retry_print': 'Reprint Receipt',
      'items': 'items',
      'payment_status': 'Payment Status',
      'success_status': 'Success',
      'failed_status': 'Failed',
      'refunded_status': 'Refunded',
      'empty_transactions': 'No Orders Yet',
      'empty_transactions_subtitle': 'Sold orders will appear here',

      // Account/Settings
      'profile': 'Profile Info',
      'theme': 'Theme',
      'printer_settings': 'Printer Settings',
      'about': 'About',
      'language': 'Language',
      'sign_out': 'Sign Out',
      'delete_account': 'Delete Account',
      'dark_mode': 'Dark Mode',
      'about_title': 'App Information',
      'about_description': 'ONI Mobile POS is a handheld sales management application belonging to the ONI ERP ecosystem, helping to operate your store professionally, quickly and accurately.',
      'language_title': 'App Language',
      'select_language': 'Select Language',
      'confirm_sign_out': 'Are you sure you want to sign out?',
      'confirm_delete_account': 'Delete Account',
      'confirm_delete_account_warn': 'Are you sure you want to permanently delete your account? This action cannot be undone and all local and remote POS data will be deleted.',
      'select_printer': 'Select Printer',
      'paper_size': 'Paper Size',
      'print_test': 'Print Test',
      'out_of_stock': 'Out of stock',
      'sold': 'Sold',
      'remove_all': 'Remove All',
      'remove_all_confirm': 'Are you sure want to remove all products?',
      'remove_confirm': 'Are you sure want to remove this product?',
      'products_label': 'Products',
      'pcs_label': 'pcs',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Easy short hands
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get close => translate('close');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get error => translate('error');
  String get success => translate('success');
  String get warning => translate('warning');
  String get search => translate('search');
  String get empty => translate('empty');
  String get loading => translate('loading');
  String get submit => translate('submit');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get create => translate('create');
  String get add => translate('add');
  String get remove => translate('remove');
  String get total => translate('total');
  String get subtotal => translate('subtotal');
  String get status => translate('status');
  String get date => translate('date');
  String get time => translate('time');

  String get welcomeTitle => translate('welcome_title');
  String get welcomeSubtitle => translate('welcome_subtitle');

  String get subdomainLabel => translate('subdomain_label');
  String get subdomainHint => translate('subdomain_hint');
  String get subdomainError => translate('subdomain_error');
  String get emailLabel => translate('email_label');
  String get emailHint => translate('email_hint');
  String get emailError => translate('email_error');
  String get passwordLabel => translate('password_label');
  String get passwordError => translate('password_error');
  String get signInButton => translate('sign_in_button');
  String get signInLoading => translate('sign_in_loading');
  String get signInFailed => translate('sign_in_failed');

  String get navSales => translate('nav_sales');
  String get navProducts => translate('nav_products');
  String get navTransactions => translate('nav_transactions');
  String get navAccount => translate('nav_account');

  String get searchProductsHint => translate('search_products_hint');
  String get selectCustomer => translate('select_customer');
  String get noCustomer => translate('no_customer');
  String get addCustomer => translate('add_customer');
  String get emptyCart => translate('empty_cart');
  String get emptyCartSubtitle => translate('empty_cart_subtitle');
  String get pay => translate('pay');
  String get addDiscount => translate('add_discount');
  String get discount => translate('discount');
  String get tax => translate('tax');
  String get paymentDetail => translate('payment_detail');
  String get paymentSuccess => translate('payment_success');
  String get changeAmount => translate('change_amount');
  String get paidAmount => translate('paid_amount');
  String get payNow => translate('pay_now');
  String get cash => translate('cash');
  String get customPayment => translate('custom_payment');
  String get receipt => translate('receipt');
  String get printReceipt => translate('print_receipt');
  String get shareReceipt => translate('share_receipt');
  String get successCheckout => translate('success_checkout');
  String get cannotCheckoutEmpty => translate('cannot_checkout_empty');
  String get transactionAmount => translate('transaction_amount');
  String get changeReturned => translate('change_returned');

  String get selectShopTitle => translate('select_shop_title');
  String get selectShopSubtitle => translate('select_shop_subtitle');
  String get selectShopButton => translate('select_shop_button');
  String get noShopFound => translate('no_shop_found');

  String get categories => translate('categories');
  String get allCategories => translate('all_categories');
  String get createProduct => translate('create_product');
  String get editProduct => translate('edit_product');
  String get productName => translate('product_name');
  String get priceLabel => translate('price');
  String get costPrice => translate('cost_price');
  String get stockLabel => translate('stock');
  String get skuLabel => translate('sku');
  String get barcodeLabel => translate('barcode');
  String get descriptionLabel => translate('description');
  String get selectCategory => translate('select_category');
  String get saveProduct => translate('save_product');
  String get deleteProduct => translate('delete_product');
  String get confirmDeleteProduct => translate('confirm_delete_product');
  String get nameRequired => translate('name_required');
  String get priceRequired => translate('price_required');
  String get costRequired => translate('cost_required');
  String get stockRequired => translate('stock_required');

  String get searchTransactions => translate('search_transactions');
  String get transactionDetail => translate('transaction_detail');
  String get orderId => translate('order_id');
  String get cashier => translate('cashier');
  String get customer => translate('customer');
  String get changeLabel => translate('change');
  String get methodLabel => translate('method');
  String get printedLabel => translate('printed');
  String get retryPrint => translate('retry_print');
  String get itemsLabel => translate('items');
  String get paymentStatus => translate('payment_status');
  String get successStatus => translate('success_status');
  String get failedStatus => translate('failed_status');
  String get refundedStatus => translate('refunded_status');
  String get emptyTransactions => translate('empty_transactions');
  String get emptyTransactionsSubtitle => translate('empty_transactions_subtitle');

  String get profile => translate('profile');
  String get theme => translate('theme');
  String get printerSettings => translate('printer_settings');
  String get aboutLabel => translate('about');
  String get languageLabel => translate('language');
  String get signOut => translate('sign_out');
  String get deleteAccount => translate('delete_account');
  String get darkMode => translate('dark_mode');
  String get aboutTitle => translate('about_title');
  String get aboutDescription => translate('about_description');
  String get languageTitle => translate('language_title');
  String get selectLanguage => translate('select_language');
  String get confirmSignOut => translate('confirm_sign_out');
  String get confirmDeleteAccount => translate('confirm_delete_account');
  String get confirmDeleteAccountWarn => translate('confirm_delete_account_warn');
  String get selectPrinter => translate('select_printer');
  String get paperSize => translate('paper_size');
  String get printTest => translate('print_test');
  String get outOfStock => translate('out_of_stock');
  String get soldLabel => translate('sold');
  String get removeAll => translate('remove_all');
  String get removeAllConfirm => translate('remove_all_confirm');
  String get removeConfirm => translate('remove_confirm');
  String get productsLabel => translate('products_label');
  String get pcsLabel => translate('pcs_label');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
