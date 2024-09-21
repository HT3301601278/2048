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
      debugShowCheckedModeBanner: false,
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

class _Game2048State extends State<Game2048> {
  List<List<int>> board = List.generate(4, (_) => List.filled(4, 0));
  List<List<int>> prevBoard = List.generate(4, (_) => List.filled(4, 0));
  List<List<bool>> mergedBoard = List.generate(4, (_) => List.filled(4, false));
  int score = 0;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    addNewTile();
    addNewTile();
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
    List<List<bool>> newMergedBoard = List.generate(4, (_) => List.filled(4, false));

    for (int i = 0; i < 4; i++) {
      List<int> row = board[i].where((tile) => tile != 0).toList();
      int k = 0;
      int newPos = 0;
      while (k < row.length) {
        if (k < row.length - 1 && row[k] == row[k + 1]) {
          newBoard[i][newPos] = row[k] * 2;
          score += newBoard[i][newPos];
          newMergedBoard[i][newPos] = true;
          changed = true;
          k += 2;
        } else {
          newBoard[i][newPos] = row[k];
          k += 1;
        }
        newPos += 1;
      }
      for (int j = newPos; j < 4; j++) {
        newBoard[i][j] = 0;
      }
      for (int j = 0; j < 4; j++) {
        if (board[i][j] != newBoard[i][j]) {
          changed = true;
        }
      }
    }

    if (changed) {
      setState(() {
        prevBoard = List.from(board.map((row) => List<int>.from(row)));
        board = newBoard;
        mergedBoard = newMergedBoard;
      });

      addNewTile();
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
      prevBoard = List.generate(4, (_) => List.filled(4, 0));
      mergedBoard = List.generate(4, (_) => List.filled(4, false));
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
            icon: const Icon(Icons.refresh),
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
              padding: const EdgeInsets.all(10),
              child: Column(
                children: List.generate(4, (i) =>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (j) =>
                          AnimatedTileWidget(
                            value: board[i][j],
                            isMerged: mergedBoard[i][j],
                          )
                      ),
                    )
                ),
              ),
            ),
          ),
          if (isGameOver())
            ElevatedButton(
              child: const Text('游戏结束! 重新开始'),
              onPressed: restartGame,
            ),
        ],
      ),
    );
  }
}

class AnimatedTileWidget extends StatefulWidget {
  final int value;
  final bool isMerged;

  const AnimatedTileWidget({
    Key? key,
    required this.value,
    required this.isMerged,
  }) : super(key: key);

  @override
  _AnimatedTileWidgetState createState() => _AnimatedTileWidgetState();
}

class _AnimatedTileWidgetState extends State<AnimatedTileWidget> with SingleTickerProviderStateMixin {
  late AnimationController _localController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _localController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _localController,
        curve: Curves.easeOutBack,
      ),
    );

    if (widget.isMerged) {
      _localController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isMerged && widget.isMerged) {
      _localController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Container(
          width: 70,
          height: 70,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _getColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: ScaleTransition(
              scale: widget.isMerged ? _scaleAnimation : AlwaysStoppedAnimation(1.0),
              child: _buildText(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildText() {
    return Text(
      widget.value > 0 ? widget.value.toString() : '',
      style: TextStyle(
        fontSize: widget.value > 512 ? 24 : 32,
        fontWeight: FontWeight.bold,
        color: widget.value > 4 ? Colors.white : Colors.black87,
      ),
    );
  }

  Color _getColor() {
    switch (widget.value) {
      case 2:
        return Colors.lightBlue[100]!;
      case 4:
        return Colors.lightBlue[200]!;
      case 8:
        return Colors.lightBlue[300]!;
      case 16:
        return Colors.lightBlue[400]!;
      case 32:
        return Colors.lightBlue[500]!;
      case 64:
        return Colors.lightBlue[600]!;
      case 128:
        return Colors.lightBlue[700]!;
      case 256:
        return Colors.lightBlue[800]!;
      case 512:
        return Colors.lightBlue[900]!;
      case 1024:
        return Colors.amber[500]!;
      case 2048:
        return Colors.amber[700]!;
      default:
        return Colors.grey[300]!;
    }
  }
}