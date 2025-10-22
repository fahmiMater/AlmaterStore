import '../core/app_response.dart';
import '../models/Order.dart';


class OrderItemsService {
  final List<Orderitem> _orderItems = [];
static final OrderItemsService _instance = OrderItemsService._internal();
  OrderItemsService._internal();
  factory OrderItemsService() {
    return _instance;
  }
  /// Add an item: if the same (productId, orderId) exists, increase its quantity,
  /// otherwise append a new item.
  AppResponse<Orderitem> addOrderItem(Orderitem item) {
    if (item.quantity <= 0) {
      return AppResponse.failure(
        'Quantity must be greater than zero.',
        code: ErrorCode.invalidInput,
      );
    }

    final idx = _orderItems.indexWhere(
      (oi) => oi.product.id == item.product.id && oi.order.id == item.order.id,
    );

    if (idx >= 0) {
      // Update existing item quantity
      _orderItems[idx].quantity += item.quantity;
      return AppResponse.success(
        _orderItems[idx],
        message:
            'Updated ${item.product.title} quantity to ${_orderItems[idx].quantity}.',
      );
    }

    // Add as new
    _orderItems.add(item);
    return AppResponse.success(
      item,
      message: 'Added ${item.product.title} to order ${item.order.id}.',
    );
  }

  /// Read-only view of items to avoid external mutation.
  AppResponse<List<Orderitem>> getOrderItems() {
    return AppResponse.success(
      List<Orderitem>.unmodifiable(_orderItems),
      message: 'Fetched ${_orderItems.length} order items.',
    );
  }

  /// Find an item; returns null if not found (null-safe).
  AppResponse<Orderitem> getOrderItemById(String productId, int orderId) {
    for (final item in _orderItems) {
      if (item.product.id == productId && item.order.id == orderId) {
        return AppResponse.success(item, message: 'Order item found.');
      }
    }
    return AppResponse.failure(
      'Item not found for product $productId in order $orderId.',
      code: ErrorCode.notFound,
    );
  }

  /// Update quantity if the item exists.
  AppResponse<Orderitem> updateOrderItemQuantity(
    String productId,
    int orderId,
    int newQuantity,
  ) {
    if (newQuantity <= 0) {
      return AppResponse.failure(
        'Quantity must be greater than zero.',
        code: ErrorCode.invalidInput,
      );
    }

    final response = getOrderItemById(productId, orderId);
    if (!response.isSuccess || response.data == null) {
      return response;
    }

    response.data!.quantity = newQuantity;
    return AppResponse.success(
      response.data!,
      message: 'Quantity updated to $newQuantity.',
    );
  }

  /// Remove an item; returns whether anything was removed.
  AppResponse<bool> deleteOrderItem(String productId, int orderId) {
    final response = getOrderItemById(productId, orderId);
    if (!response.isSuccess || response.data == null) {
      return AppResponse.failure(
        response.message,
        code: response.error ?? ErrorCode.notFound,
      );
    }

    _orderItems.remove(response.data);
    return AppResponse.success(
      true,
      message: 'Item removed from order $orderId.',
    );
  }
}
