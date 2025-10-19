import '../data/quote_repository.dart';

class QuoteLogic {
  final QuoteRepository _repo = QuoteRepository();

  Future<Map<String, String>> getDailyQuote() async {
    return await _repo.fetchDailyQuote();
  }
}
