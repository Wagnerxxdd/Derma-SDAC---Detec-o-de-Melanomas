import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AiService {
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
      }
    }

    if (pairs == 0) {
      return {
        "contrast": 0,
        "energy": 0,
        "homogeneity": 0,
        "correlation": 0,
        "entropy": 0
      };
    }

    for (var i = 0; i < levels; i++) {
      for (var j = 0; j < levels; j++) {
        matrix[i][j] /= pairs;
      }
    }

    double contrast = 0;
    double energy = 0;
    double homogeneity = 0;
    double entropy = 0;

    for (var i = 0; i < levels; i++) {
      for (var j = 0; j < levels; j++) {
        final p = matrix[i][j];

        contrast += (i - j) * (i - j) * p;
        energy += p * p;
        homogeneity += p / (1 + (i - j).abs());

        if (p > 0) {
          entropy -= p * math.log(p);
        }
      }
    }

    return {
      "contrast": contrast,
      "energy": energy,
      "homogeneity": homogeneity,
      "correlation": 0,
      "entropy": entropy
    };
  }

  double _dice(List<List<bool>> mask, List<int> Function(int, int) transform) {
    int inter = 0;
    int a = 0;
    int b = 0;

    for (int y = 0; y < 512; y++) {
      for (int x = 0; x < 512; x++) {
        final m1 = mask[y][x];

        final t = transform(x, y);

        final tx = t[0];
        final ty = t[1];

        if (tx < 0 || ty < 0 || tx >= 512 || ty >= 512) continue;

        final m2 = mask[ty][tx];

        if (m1) a++;
        if (m2) b++;
        if (m1 && m2) inter++;
      }
    }

    if (a + b == 0) return 0;

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
        }
      }
    }

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
  }
}
