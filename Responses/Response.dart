class Response {
  successful({String? message, data}) {
    return {'status': 'success', 'message': message, 'data': data};
  }
  error(String message) {
    return {'status': 'error', 'message': message};
  }
  
}