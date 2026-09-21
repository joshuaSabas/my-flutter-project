import 'dart:convert';
import 'package:flutter/services.dart';

class RandomForestService {
  List<Map<String, dynamic>> _trees = [];
  List<String> _classes = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      final jsonString = await rootBundle.loadString('assets/random_forest.json');
      final data = json.decode(jsonString);

      _trees = List<Map<String, dynamic>>.from(data['trees']);
      _classes = List<String>.from(data['classes']);
      _isLoaded = true;

      print('✅ Random Forest loaded! Trees: ${_trees.length}, Classes: ${_classes.length}');
    } catch (e) {
      print('❌ Error loading Random Forest: $e');
      _isLoaded = false;
    }
  }

  String predict({
    required double n,
    required double p,
    required double k,
    required double ph,
  }) {
    if (!_isLoaded) return 'Model not loaded';

    final features = [n, p, k, ph];
    final votes = List<int>.filled(_classes.length, 0);

    for (final tree in _trees) {
      final prediction = _predictTree(tree, features);
      votes[prediction]++;
    }

    int maxVotes = 0;
    int maxIndex = 0;
    for (int i = 0; i < votes.length; i++) {
      if (votes[i] > maxVotes) {
        maxVotes = votes[i];
        maxIndex = i;
      }
    }

    return _classes[maxIndex];
  }

  int _predictTree(Map<String, dynamic> tree, List<double> features) {
    final childrenLeft = List<int>.from(tree['children_left']);
    final childrenRight = List<int>.from(tree['children_right']);
    final feature = List<int>.from(tree['feature']);
    final threshold = List<double>.from(tree['threshold']);
    final value = tree['value'];

    int node = 0;

    while (childrenLeft[node] != -1) {
      if (features[feature[node]] <= threshold[node]) {
        node = childrenLeft[node];
      } else {
        node = childrenRight[node];
      }
    }

    final leafValue = value[node][0] as List<dynamic>;
    int maxIndex = 0;
    double maxVal = (leafValue[0] as num).toDouble();

    for (int i = 1; i < leafValue.length; i++) {
      final v = (leafValue[i] as num).toDouble();
      if (v > maxVal) {
        maxVal = v;
        maxIndex = i;
      }
    }

    return maxIndex;
  }
}
