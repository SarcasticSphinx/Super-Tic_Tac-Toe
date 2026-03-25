import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum Player { none, o, x, draw }

class GameStateProvider with ChangeNotifier {
  List<List<Player>> innerGrids = List.generate(9, (_) => List.generate(9, (_) => Player.none));
  List<Player> outerGrid = List.generate(9, (_) => Player.none);

  bool turnO = true;
  int? selectedOuterIndex; // null means free move
  Player winner = Player.none;
  bool isDraw = false;

  GameStateProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString('gameState');
    if (stateJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(stateJson);
        turnO = data['turnO'];
        selectedOuterIndex = data['selectedOuterIndex'];
        winner = Player.values.firstWhere((e) => e.name == data['winner']);
        isDraw = data['isDraw'];

        outerGrid = (data['outerGrid'] as List).map((e) => Player.values.firstWhere((p) => p.name == e)).toList();

        innerGrids = (data['innerGrids'] as List).map((innerList) {
          return (innerList as List).map((e) => Player.values.firstWhere((p) => p.name == e)).toList();
        }).toList();

        notifyListeners();
      } catch (e) {
        resetGame();
      }
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'turnO': turnO,
      'selectedOuterIndex': selectedOuterIndex,
      'winner': winner.name,
      'isDraw': isDraw,
      'outerGrid': outerGrid.map((e) => e.name).toList(),
      'innerGrids': innerGrids.map((inner) => inner.map((e) => e.name).toList()).toList(),
    };
    await prefs.setString('gameState', jsonEncode(data));
  }

  void resetGame() {
    innerGrids = List.generate(9, (_) => List.generate(9, (_) => Player.none));
    outerGrid = List.generate(9, (_) => Player.none);
    turnO = true;
    selectedOuterIndex = null;
    winner = Player.none;
    isDraw = false;
    _saveState();
    notifyListeners();
  }

  bool isFreeMove() => selectedOuterIndex == null;

  void playMove(int outerIndex, int innerIndex) {
    if (winner != Player.none || isDraw) return; // Game over
    if (outerGrid[outerIndex] != Player.none) return; // Outer grid already won/drawn
    if (selectedOuterIndex != null && selectedOuterIndex != outerIndex) return; // Invalid move
    if (innerGrids[outerIndex][innerIndex] != Player.none) return; // Cell already taken

    // Make the move
    innerGrids[outerIndex][innerIndex] = turnO ? Player.o : Player.x;

    // Check inner win
    Player innerWinner = _checkWin(innerGrids[outerIndex]);
    if (innerWinner != Player.none) {
      outerGrid[outerIndex] = innerWinner;
    } else if (!innerGrids[outerIndex].contains(Player.none)) {
      // Draw in inner grid
      outerGrid[outerIndex] = Player.draw;
    }

    // Check overall win
    winner = _checkWin(outerGrid);
    if (winner == Player.none && !outerGrid.contains(Player.none)) {
      isDraw = true;
    }

    // Next turn setup
    turnO = !turnO;
    if (outerGrid[innerIndex] != Player.none) {
      selectedOuterIndex = null; // Free move
    } else {
      selectedOuterIndex = innerIndex;
    }

    _saveState();
    notifyListeners();
  }

  Player _checkWin(List<Player> grid) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (var pattern in winPatterns) {
      if (grid[pattern[0]] != Player.none &&
          grid[pattern[0]] != Player.draw &&
          grid[pattern[0]] == grid[pattern[1]] &&
          grid[pattern[1]] == grid[pattern[2]]) {
        return grid[pattern[0]];
      }
    }
    return Player.none;
  }
}
