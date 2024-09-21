import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048游戏',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Game2048(),
    );
  }
}

class Game2048 extends StatefulWidget {
  const Game2048({Key? key}) : super(key: key);

  @override
  _Game2048State createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> with TickerProviderStateMixin {
  List<List<int>> board = List.generate(4, (_) => List.filled(4, 0));
  List<List<int>> prevBoard = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  Random random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    addNewTile();
    addNewTile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addNewTile() {
    List<List<int>> emptyTiles = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) {
          emptyTiles.add([i, j]);
        }
      }
    }
    if (emptyTiles.isNotEmpty) {
      List<int> newTile = emptyTiles[random.nextInt(emptyTiles.length)];
      board[newTile[0]][newTile[1]] = random.nextInt(10) < 9 ? 2 : 4;
    }
  }

  void moveLeft() {
    bool changed = false;
    List<List<int>> newBoard = List.generate(4, (_) => List.filled(4, 0));

    for (int i = 0; i < 4; i++) {
      List<int> row = board[i].where((tile) => tile != 0).toList();
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j] == row[j + 1]) {
          row[j] *= 2;
          score += row[j];
          row.removeAt(j + 1);
          changed = true;
        }
      }
      row = row + List.filled(4 - row.length, 0);
      if (board[i] != row) changed = true;
      newBoard[i] = row;
    }

    if (changed) {
      setState(() {
        prevBoard = List.from(board.map((row) => List<int>.from(row)));
        board = newBoard;
      });

      _controller.forward(from: 0).then((_) {
        setState(() {
          addNewTile();
        });
      });
    }
  }

  void moveRight() {
    board = board.map((row) => row.reversed.toList()).toList();
    moveLeft();
    board = board.map((row) => row.reversed.toList()).toList();
  }

  void moveUp() {
    board = List.generate(4, (j) => List.generate(4, (i) => board[i][j]));
    moveLeft();
    board = List.generate(4, (i) => List.generate(4, (j) => board[j][i]));
  }

  void moveDown() {
    board = List.generate(4, (j) => List.generate(4, (i) => board[i][j]));
    moveRight();
    board = List.generate(4, (i) => List.generate(4, (j) => board[j][i]));
  }

  bool isGameOver() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) return false;
        if (i < 3 && board[i][j] == board[i + 1][j]) return false;
        if (j < 3 && board[i][j] == board[i][j + 1]) return false;
      }
    }
    return true;
  }

  void restartGame() {
    setState(() {
      board = List.generate(4, (_) => List.filled(4, 0));
      prevBoard = List.generate(4, (_) => List<int>.filled(4, 0));
      score = 0;
      addNewTile();
      addNewTile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2048 - 分数: $score'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: restartGame,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < 0) {
                moveUp();
              } else {
                moveDown();
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx < 0) {
                moveLeft();
              } else {
                moveRight();
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: List.generate(4, (i) =>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (j) =>
                          AnimatedTileWidget(
                            value: board[i][j],
                            prevValue: prevBoard[i][j],
                            isNew: board[i][j] != 0 && prevBoard[i][j] == 0,
                            animation: _controller,
                          )
                      ),
                    )
                ),
              ),
            ),
          ),
          if (isGameOver())
            ElevatedButton(
              child: Text('游戏结束! 重新开始'),
              onPressed: restartGame,
            ),
        ],
      ),
    );
  }
}

class AnimatedTileWidget extends StatelessWidget {
  final int value;
  final int prevValue;
  final bool isNew;
  final Animation<double> animation;

  AnimatedTileWidget({
    required this.value,
    required this.prevValue,
    required this.isNew,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasChanged = value != prevValue;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 70,
          height: 70,
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _getColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: hasChanged || isNew
                ? ScaleTransition(
              scale: Tween<double>(
                begin: isNew ? 0.0 : 0.5,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: _buildText(),
            )
                : _buildText(),
          ),
        );
      },
    );
  }

  Widget _buildText() {
    return Text(
      value > 0 ? value.toString() : '',
      style: TextStyle(
        fontSize: value > 512 ? 24 : 32,
        fontWeight: FontWeight.bold,
        color: value > 4 ? Colors.white : Colors.black87,
      ),
    );
  }

  Color _getColor() {
    switch (value) {
      case 2: return Colors.lightBlue[100]!;
      case 4: return Colors.lightBlue[200]!;
      case 8: return Colors.lightBlue[300]!;
      case 16: return Colors.lightBlue[400]!;
      case 32: return Colors.lightBlue[500]!;
      case 64: return Colors.lightBlue[600]!;
      case 128: return Colors.lightBlue[700]!;
      case 256: return Colors.lightBlue[800]!;
      case 512: return Colors.lightBlue[900]!;
      case 1024: return Colors.amber[500]!;
      case 2048: return Colors.amber[700]!;
      default: return Colors.grey[300]!;
    }
  }
}