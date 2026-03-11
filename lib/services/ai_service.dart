import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AiService {
<<<<<<< HEAD
  Interpreter? _segmentationInterpreter;
  Interpreter? _classificationInterpreter;
  Map<String, dynamic>? _config;

  Future<void> loadModels() async {
    _segmentationInterpreter =
        await Interpreter.fromAsset('assets/models/512_unet_melanoma.tflite');

    _classificationInterpreter =
        await Interpreter.fromAsset('assets/models/modeloMLP.tflite');

    final jsonString =
        await rootBundle.loadString('assets/models/config_frontend.json');

    _config = json.decode(jsonString);
  }

  Future<Map<String, dynamic>> runAnalysis(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes)!;

    /// sempre trabalhar em 512
    final image = img.copyResize(original, width: 512, height: 512);

    final mask = _runSegmentation(image);

    final features = _extractFeatures(image, mask);

    final normalized = _normalize(features);

    final input = [normalized];
    final output = List.filled(1, 0.0).reshape([1, 1]);

    _classificationInterpreter!.run(input, output);

    final score = output[0][0];
    final threshold = (_config!["limiar_decisao"] as num).toDouble();

    return {
      "score": score,
      "isMelanoma": score > threshold,
      "probabilidade": score * 100
    };
  }

  List<List<bool>> _runSegmentation(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        512,
        (y) => List.generate(
          512,
          (x) {
            final p = image.getPixel(x, y);
            return [p.r / 255, p.g / 255, p.b / 255];
          },
        ),
      ),
    );

    final output = List.generate(
      1,
      (_) => List.generate(
        512,
        (_) => List.generate(512, (_) => [0.0]),
      ),
    );

    _segmentationInterpreter!.run(input, output);

    return List.generate(
      512,
      (y) => List.generate(
        512,
        (x) => output[0][y][x][0] > 0.5,
      ),
    );
  }

  List<double> _extractFeatures(img.Image image, List<List<bool>> mask) {
    final gray = List.generate(
      512,
      (y) => List<double>.generate(512, (x) {
        final p = image.getPixel(x, y);
        return 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
      }),
    );

    final glcm0 = _glcm(gray, mask, 1, 0);
    final glcm45 = _glcm(gray, mask, 1, -1);
    final glcm90 = _glcm(gray, mask, 0, 1);
    final glcm135 = _glcm(gray, mask, -1, -1);

    final diceH = _dice(mask, (x, y) => [511 - x, y]);
    final diceV = _dice(mask, (x, y) => [x, 511 - y]);
    final diceD1 = _dice(mask, (x, y) => [511 - x, 511 - y]);
    final diceD2 = _dice(mask, (x, y) => [y, x]);

    final assimetria = 1 - ((diceH + diceV + diceD1 + diceD2) / 4);

    final compactness = _compactness(mask);

    final crFactor = _colorRatio(image, mask);

    final featureMap = {
      "contraste_0": glcm0["contrast"],
      "energia_0": glcm0["energy"],
      "homogeneidade_0": glcm0["homogeneity"],
      "correlacao_0": glcm0["correlation"],
      "entropia_0": glcm0["entropy"],
      "contraste_45": glcm45["contrast"],
      "energia_45": glcm45["energy"],
      "homogeneidade_45": glcm45["homogeneity"],
      "correlacao_45": glcm45["correlation"],
      "entropia_45": glcm45["entropy"],
      "contraste_90": glcm90["contrast"],
      "energia_90": glcm90["energy"],
      "homogeneidade_90": glcm90["homogeneity"],
      "correlacao_90": glcm90["correlation"],
      "entropia_90": glcm90["entropy"],
      "contraste_135": glcm135["contrast"],
      "energia_135": glcm135["energy"],
      "homogeneidade_135": glcm135["homogeneity"],
      "correlacao_135": glcm135["correlation"],
      "entropia_135": glcm135["entropy"],
      "dice_horizontal": diceH,
      "dice_vertical": diceV,
      "dice_diagonal_xy": diceD1,
      "dice_diagonal_ynegx": diceD2,
      "assimetria_global": assimetria,
      "fourier_factor_score": 0.0,
      "compactness": compactness,
      "cr_factor": crFactor
    };

    final ordem = _config!["ordem_features"];

    return ordem.map<double>((f) => (featureMap[f] ?? 0).toDouble()).toList();
  }

  Map<String, double> _glcm(
      List<List<double>> gray, List<List<bool>> mask, int dx, int dy) {
    const levels = 16;

    final matrix = List.generate(levels, (_) => List.filled(levels, 0.0));

    double pairs = 0;

    for (int y = 0; y < 512; y++) {
      for (int x = 0; x < 512; x++) {
        final nx = x + dx;
        final ny = y + dy;

        if (nx < 0 || ny < 0 || nx >= 512 || ny >= 512) continue;

        if (!mask[y][x] || !mask[ny][nx]) continue;

        final i = ((gray[y][x] / 256) * levels).floor();
        final j = ((gray[ny][nx] / 256) * levels).floor();

        matrix[i][j] += 1;
        pairs++;
=======
  Interpreter? _classificationInterpreter;
  Map<String, dynamic>? _config;

  // Compatibilidade com o código antigo
  Future<void> loadModel() => loadModels();

  Future<void> loadModels() async {
    try {
      _classificationInterpreter = await Interpreter.fromAsset('assets/models/modeloMLP.tflite');
      
      final configString = await rootBundle.loadString('assets/models/config_frontend.json');
      _config = json.decode(configString);
      
      print('Modelos e configurações carregados com sucesso.');
    } catch (e) {
      print('Erro ao carregar modelos ou configurações: $e');
      rethrow;
    }
  }

  // Compatibilidade com o código antigo
  Future<List<dynamic>> runInference(String imagePath) async {
    final result = await runFullAnalysis(imagePath);
    return [result];
  }

  Future<Map<String, dynamic>> runFullAnalysis(String imagePath) async {
    if (_classificationInterpreter == null || _config == null) {
      throw Exception('Interpretadores não carregados.');
    }

    final imageBytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception('Não foi possível decodificar a imagem.');
    }
    final resizedImage = img.copyResize(originalImage, width: 256, height: 256);
    final features = _extractFeaturesFromImage(resizedImage);
    final normalizedFeatures = _normalizeFeatures(features);

    final inputClassification = [normalizedFeatures];
    final outputClassification = List.filled(1 * 1, 0.0).reshape([1, 1]);
    _classificationInterpreter!.run(inputClassification, outputClassification);
    
    final double score = outputClassification[0][0];
    final double threshold = (_config!['limiar_decisao'] as num).toDouble();

    return {
      'score': score,
      'threshold': threshold,
      'isMalignant': score > threshold,
      'malignantProb': score * 100,
    };
  }

  List<double> _extractFeaturesFromImage(img.Image image) {
    final gray = List.generate(
      image.height,
      (y) => List<double>.generate(image.width, (x) {
        final pixel = image.getPixel(x, y);
        return 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
      }),
    );

    final threshold = _otsuThreshold(gray);
    var mask = List.generate(
      image.height,
      (y) => List<bool>.generate(image.width, (x) => gray[y][x] < threshold),
    );

    final areaDark = _maskArea(mask).toDouble();
    final totalArea = (image.width * image.height).toDouble();
    if (areaDark < totalArea * 0.01 || areaDark > totalArea * 0.9) {
      mask = List.generate(
        image.height,
        (y) => List<bool>.generate(image.width, (x) => gray[y][x] > threshold),
      );
    }

    final glcm0 = _computeGlcmFeatures(gray, mask, 1, 0);
    final glcm45 = _computeGlcmFeatures(gray, mask, 1, -1);
    final glcm90 = _computeGlcmFeatures(gray, mask, 0, 1);
    final glcm135 = _computeGlcmFeatures(gray, mask, -1, -1);

    final diceHorizontal = _diceWithTransform(mask, (x, y, w, h) => [w - 1 - x, y]);
    final diceVertical = _diceWithTransform(mask, (x, y, w, h) => [x, h - 1 - y]);
    final diceDiagXY = _diceWithTransform(mask, (x, y, w, h) => [y, x]);
    final diceDiagYnegX = _diceWithTransform(mask, (x, y, w, h) => [w - 1 - y, h - 1 - x]);

    final asymmetryGlobal = 1.0 - ((diceHorizontal + diceVertical + diceDiagXY + diceDiagYnegX) / 4.0);
    final fourierFactorScore = _edgeComplexity(gray, mask);
    final compactness = _compactness(mask);
    final crFactor = _colorRatioFactor(image, mask);

    final featureMap = <String, double>{
      'contraste_0': glcm0['contrast']!,
      'energia_0': glcm0['energy']!,
      'homogeneidade_0': glcm0['homogeneity']!,
      'correlacao_0': glcm0['correlation']!,
      'entropia_0': glcm0['entropy']!,
      'contraste_45': glcm45['contrast']!,
      'energia_45': glcm45['energy']!,
      'homogeneidade_45': glcm45['homogeneity']!,
      'correlacao_45': glcm45['correlation']!,
      'entropia_45': glcm45['entropy']!,
      'contraste_90': glcm90['contrast']!,
      'energia_90': glcm90['energy']!,
      'homogeneidade_90': glcm90['homogeneity']!,
      'correlacao_90': glcm90['correlation']!,
      'entropia_90': glcm90['entropy']!,
      'contraste_135': glcm135['contrast']!,
      'energia_135': glcm135['energy']!,
      'homogeneidade_135': glcm135['homogeneity']!,
      'correlacao_135': glcm135['correlation']!,
      'entropia_135': glcm135['entropy']!,
      'dice_horizontal': diceHorizontal,
      'dice_vertical': diceVertical,
      'dice_diagonal_xy': diceDiagXY,
      'dice_diagonal_ynegx': diceDiagYnegX,
      'assimetria_global': asymmetryGlobal,
      'fourier_factor_score': fourierFactorScore,
      'compactness': compactness,
      'cr_factor': crFactor,
    };

    final List<dynamic> order = _config!['ordem_features'];
    return order
        .map((name) => (featureMap[name.toString()] ?? 0.0).toDouble())
        .toList(growable: false);
  }

  double _otsuThreshold(List<List<double>> gray) {
    final hist = List<int>.filled(256, 0);
    int total = 0;
    double sum = 0;
    for (final row in gray) {
      for (final v in row) {
        final idx = v.clamp(0, 255).toInt();
        hist[idx]++;
        total++;
        sum += idx;
      }
    }

    double sumB = 0;
    int wB = 0;
    double maxVar = -1;
    int threshold = 127;

    for (var t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;
      final wF = total - wB;
      if (wF == 0) break;

      sumB += t * hist[t];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final between = wB * wF * (mB - mF) * (mB - mF);

      if (between > maxVar) {
        maxVar = between;
        threshold = t;
      }
    }
    return threshold.toDouble();
  }

  int _maskArea(List<List<bool>> mask) {
    var area = 0;
    for (final row in mask) {
      for (final v in row) {
        if (v) area++;
      }
    }
    return area;
  }

  Map<String, double> _computeGlcmFeatures(
    List<List<double>> gray,
    List<List<bool>> mask,
    int dx,
    int dy,
  ) {
    const levels = 16;
    final glcm = List.generate(levels, (_) => List<double>.filled(levels, 0.0));
    final h = gray.length;
    final w = gray[0].length;
    double pairs = 0;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        if (!mask[y][x] || !mask[ny][nx]) continue;

        final i = ((gray[y][x] / 256.0) * levels).floor().clamp(0, levels - 1);
        final j = ((gray[ny][nx] / 256.0) * levels).floor().clamp(0, levels - 1);
        glcm[i][j] += 1.0;
        pairs += 1.0;
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
      }
    }

    if (pairs == 0) {
      return {
<<<<<<< HEAD
        "contrast": 0,
        "energy": 0,
        "homogeneity": 0,
        "correlation": 0,
        "entropy": 0
=======
        'contrast': 0,
        'energy': 0,
        'homogeneity': 0,
        'correlation': 0,
        'entropy': 0,
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
      };
    }

    for (var i = 0; i < levels; i++) {
      for (var j = 0; j < levels; j++) {
<<<<<<< HEAD
        matrix[i][j] /= pairs;
=======
        glcm[i][j] /= pairs;
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
      }
    }

    double contrast = 0;
    double energy = 0;
    double homogeneity = 0;
    double entropy = 0;
<<<<<<< HEAD

    for (var i = 0; i < levels; i++) {
      for (var j = 0; j < levels; j++) {
        final p = matrix[i][j];

        contrast += (i - j) * (i - j) * p;
        energy += p * p;
        homogeneity += p / (1 + (i - j).abs());

        if (p > 0) {
          entropy -= p * math.log(p);
=======
    final px = List<double>.filled(levels, 0.0);
    final py = List<double>.filled(levels, 0.0);

    for (var i = 0; i < levels; i++) {
      for (var j = 0; j < levels; j++) {
        final p = glcm[i][j];
        contrast += (i - j) * (i - j) * p;
        energy += p * p;
        homogeneity += p / (1 + (i - j).abs());
        if (p > 0) entropy -= p * (math.log(p) / math.ln2);
        px[i] += p;
        py[j] += p;
      }
    }

    double meanX = 0;
    double meanY = 0;
    for (var i = 0; i < levels; i++) {
      meanX += i * px[i];
      meanY += i * py[i];
    }

    double stdX = 0;
    double stdY = 0;
    for (var i = 0; i < levels; i++) {
      stdX += (i - meanX) * (i - meanX) * px[i];
      stdY += (i - meanY) * (i - meanY) * py[i];
    }
    stdX = math.sqrt(stdX);
    stdY = math.sqrt(stdY);

    double correlation = 0;
    if (stdX > 1e-12 && stdY > 1e-12) {
      for (var i = 0; i < levels; i++) {
        for (var j = 0; j < levels; j++) {
          correlation += ((i - meanX) * (j - meanY) * glcm[i][j]) / (stdX * stdY);
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
        }
      }
    }

    return {
<<<<<<< HEAD
      "contrast": contrast,
      "energy": energy,
      "homogeneity": homogeneity,
      "correlation": 0,
      "entropy": entropy
    };
  }

  double _dice(List<List<bool>> mask, List<int> Function(int, int) transform) {
=======
      'contrast': contrast,
      'energy': energy,
      'homogeneity': homogeneity,
      'correlation': correlation,
      'entropy': entropy,
    };
  }

  double _diceWithTransform(
    List<List<bool>> mask,
    List<int> Function(int x, int y, int w, int h) transform,
  ) {
    final h = mask.length;
    final w = mask[0].length;
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
    int inter = 0;
    int a = 0;
    int b = 0;

<<<<<<< HEAD
    for (int y = 0; y < 512; y++) {
      for (int x = 0; x < 512; x++) {
        final m1 = mask[y][x];

        final t = transform(x, y);

        final tx = t[0];
        final ty = t[1];

        if (tx < 0 || ty < 0 || tx >= 512 || ty >= 512) continue;

        final m2 = mask[ty][tx];
=======
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final m1 = mask[y][x];
        final t = transform(x, y, w, h);
        final tx = t[0];
        final ty = t[1];
        final m2 = (tx >= 0 && tx < w && ty >= 0 && ty < h) ? mask[ty][tx] : false;
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a

        if (m1) a++;
        if (m2) b++;
        if (m1 && m2) inter++;
      }
    }

    if (a + b == 0) return 0;
<<<<<<< HEAD

    return (2 * inter) / (a + b);
  }

  double _compactness(List<List<bool>> mask) {
    int area = 0;
    int perimeter = 0;

    for (int y = 0; y < 512; y++) {
      for (int x = 0; x < 512; x++) {
        if (!mask[y][x]) continue;

        area++;

        if (x == 0 ||
            y == 0 ||
            x == 511 ||
            y == 511 ||
            !mask[y][x - 1] ||
            !mask[y][x + 1] ||
            !mask[y - 1][x] ||
            !mask[y + 1][x]) {
          perimeter++;
        }
      }
    }

    if (perimeter == 0) return 0;

    return (4 * math.pi * area) / (perimeter * perimeter);
  }

  double _colorRatio(img.Image image, List<List<bool>> mask) {
    double lesion = 0;
    double skin = 0;

    int ln = 0;
    int sn = 0;

    for (int y = 0; y < 512; y++) {
      for (int x = 0; x < 512; x++) {
        final p = image.getPixel(x, y);
        final lum = p.r + p.g + p.b;

        if (mask[y][x]) {
          lesion += lum;
          ln++;
        } else {
          skin += lum;
          sn++;
=======
    return (2.0 * inter) / (a + b);
  }

  double _edgeComplexity(List<List<double>> gray, List<List<bool>> mask) {
    final h = gray.length;
    final w = gray[0].length;
    double gradSum = 0;
    int count = 0;

    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        if (!mask[y][x]) continue;
        final gx = gray[y][x + 1] - gray[y][x - 1];
        final gy = gray[y + 1][x] - gray[y - 1][x];
        gradSum += math.sqrt(gx * gx + gy * gy);
        count++;
      }
    }

    if (count == 0) return 0;
    return (gradSum / count) / 255.0;
  }

  double _compactness(List<List<bool>> mask) {
    final h = mask.length;
    final w = mask[0].length;
    int area = 0;
    int perimeter = 0;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (!mask[y][x]) continue;
        area++;

        final isBoundary =
            x == 0 ||
            y == 0 ||
            x == w - 1 ||
            y == h - 1 ||
            !mask[y][x - 1] ||
            !mask[y][x + 1] ||
            !mask[y - 1][x] ||
            !mask[y + 1][x];
        if (isBoundary) perimeter++;
      }
    }

    if (area == 0 || perimeter == 0) return 0;
    return (4.0 * math.pi * area) / (perimeter * perimeter);
  }

  double _colorRatioFactor(img.Image image, List<List<bool>> mask) {
    double lesionR = 0;
    double lesionG = 0;
    double lesionB = 0;
    int lesionN = 0;

    double skinR = 0;
    double skinG = 0;
    double skinB = 0;
    int skinN = 0;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        if (mask[y][x]) {
          lesionR += p.r;
          lesionG += p.g;
          lesionB += p.b;
          lesionN++;
        } else {
          skinR += p.r;
          skinG += p.g;
          skinB += p.b;
          skinN++;
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
        }
      }
    }

<<<<<<< HEAD
    if (ln == 0 || sn == 0) return 0;

    return (lesion / ln) / (skin / sn);
  }

  List<double> _normalize(List<double> features) {
    final means = _config!["scaler"]["medias"];
    final stds = _config!["scaler"]["desvios"];

    return List.generate(
        features.length, (i) => (features[i] - means[i]) / stds[i]);
  }

  void close() {
    _segmentationInterpreter?.close();
    _classificationInterpreter?.close();
=======
    if (lesionN == 0 || skinN == 0) return 0;

    final lesionLum = (lesionR + lesionG + lesionB) / lesionN;
    final skinLum = (skinR + skinG + skinB) / skinN;
    if (skinLum.abs() < 1e-12) return 0;
    return lesionLum / skinLum;
  }

  List<double> _normalizeFeatures(List<double> features) {
    final List<dynamic> means = _config!['scaler']['medias'];
    final List<dynamic> stds = _config!['scaler']['desvios'];
    return List.generate(28, (i) => (features[i] - (means[i] as num).toDouble()) / (stds[i] as num).toDouble());
  }

  void close() {
    _classificationInterpreter?.close();
    _classificationInterpreter = null;
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
  }
}
