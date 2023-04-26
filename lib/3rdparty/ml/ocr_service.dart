import 'package:snapfinance/3rdparty/ml/ocr_number.dart';

abstract class OcrService {
  Stream<OcrNumber> findNumbers(String path);
}
