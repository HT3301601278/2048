import 'dart:math';
import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

class GameController extends ChangeNotifier {
  List<int> board = List.filled(16, 0);
  int score = 0;
  int highScore = 0;
  List<List<int>> history = [];
  List<int> scoreHistory = [];
  int maxHistoryLength = 3;

  void startGame() {
    board = List.filled(16, 0);
    score = 0;
    history.clear();
    scoreHistory.clear();
    addRandomTile();
    addRandomTile();
    notifyListeners();
  }

  void addRandomTile() {
    List<int> emptyIndices = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == 0) emptyIndices.add(i);
    }
    if (emptyIndices.isNotEmpty) {
      int index = emptyIndices[Random().nextInt(emptyIndices.length)];
      board[index] = Random().nextBool() ? 2 : 4;
      print('添加了新方块：在位置 $index 添加了值 ${board[index]}');
    }
  }

  void move(Direction direction) {
    print('开始移动: $direction');
    bool moved = false;
    List<int> oldBoard = List.from(board);
    int oldScore = score;

    for (int i = 0; i < 4; i++) {
      List<int> line = [];
      for (int j = 0; j < 4; j++) {
        int index = _getIndex(i, j, direction);
        if (board[index] != 0) {
          line.add(board[index]);
        }
      }
      
      List<int> mergedLine = _mergeLine(line);
      
      int fillIndex = 0;
      for (int j = 0; j < 4; j++) {
        int index = _getIndex(i, j, direction);
        int value = fillIndex < mergedLine.length ? mergedLine[fillIndex] : 0;
        if (board[index] != value) {
          board[index] = value;
          moved = true;
        }
        if (value != 0) fillIndex++;
      }
    }

    if (moved) {
      history.add(oldBoard);
      scoreHistory.add(oldScore);
      if (history.length > maxHistoryLength) {
        history.removeAt(0);
        scoreHistory.removeAt(0);
      }
      print('移动完成，准备添加新方块');
      addRandomTile();
      if (score > highScore) {
        highScore = score;
      }
      notifyListeners();
      print('新方块添加完成，当前棋盘状态：$board');
    } else {
      print('未检测到移动，不添加新方块');
    }
  }

  void undo() {
    if (history.isNotEmpty) {
      board = history.removeLast();
      score = scoreHistory.removeLast();
      notifyListeners();
    }
  }

  bool canUndo() {
    return history.isNotEmpty;
  }

  int _getIndex(int i, int j, Direction direction) {
    switch (direction) {
      case Direction.up:
        return j * 4 + i;
      case Direction.down:
        return (3 - j) * 4 + i;
      case Direction.left:
        return i * 4 + j;
      case Direction.right:
        return i * 4 + (3 - j);
    }
  }

  List<int> _mergeLine(List<int> line) {
    List<int> merged = [];
    for (int i = 0; i < line.length; i++) {
      if (i + 1 < line.length && line[i] == line[i + 1]) {
        merged.add(line[i] * 2);
        score += line[i] * 2;
        i++;
      } else {
        merged.add(line[i]);
      }
    }
    return merged;
  }

  bool isGameOver() {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == 0) return false;
      if (i % 4 < 3 && board[i] == board[i + 1]) return false;
      if (i < 12 && board[i] == board[i + 4]) return false;
    }
    return true;
  }
}