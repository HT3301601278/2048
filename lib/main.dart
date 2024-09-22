import 'package:flutter/material.dart';
import 'game_controller.dart';
import 'game_tile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF0F0F0),
      ),
      home: GamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GameController _controller = GameController();

  Offset _startDragOffset = Offset.zero;
  bool _isSwipeInProgress = false;

  @override
  void initState() {
    super.initState();
    _controller.startGame();
    _controller.addListener(() {
      setState(() {});
      if (_controller.isGameOver()) {
        _showGameOverDialog();
      }
    });
  }

  void _handleSwipe(Direction direction) {
    if (!_isSwipeInProgress) {
      _isSwipeInProgress = true;
      print('滑动检测到: $direction');
      print('滑动前的棋盘状态: ${_controller.board}');
      setState(() {
        _controller.move(direction);
      });
      print('滑动后的棋盘状态: ${_controller.board}');
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('游戏结束'),
          content: Text('您的得分: ${_controller.score}'),
          actions: [
            TextButton(
              child: Text('重新开始'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _controller.startGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      appBar: AppBar(
        title: Text('2048', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF1565C0),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _buildScoreBoard(),
          SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                _startDragOffset = details.globalPosition;
                _isSwipeInProgress = false;
              },
              onPanUpdate: (details) {
                if (!_isSwipeInProgress) {
                  final offset = details.globalPosition - _startDragOffset;
                  if (offset.dx.abs() > offset.dy.abs()) {
                    if (offset.dx.abs() > 20) {
                      if (offset.dx < 0) {
                        print('向左滑动');
                        _handleSwipe(Direction.left);
                      } else {
                        print('向右滑动');
                        _handleSwipe(Direction.right);
                      }
                    }
                  } else {
                    if (offset.dy.abs() > 20) {
                      if (offset.dy < 0) {
                        print('向上滑动');
                        _handleSwipe(Direction.up);
                      } else {
                        print('向下滑动');
                        _handleSwipe(Direction.down);
                      }
                    }
                  }
                }
              },
              onPanEnd: (details) {
                _isSwipeInProgress = false;
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    int value = _controller.board[index];
                    return GameTile(value: value);
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.startGame();
                  });
                },
                child: Text('重新开始'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  if (_controller.canUndo()) {
                    setState(() {
                      _controller.undo();
                    });
                  } else {
                    _showCustomSnackBar(context);
                  }
                },
                child: Text('撤销'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreBox('得分', _controller.score),
        SizedBox(width: 20),
        _buildScoreBox('最高分', _controller.highScore),
      ],
    );
  }

  Widget _buildScoreBox(String title, int score) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            '$score',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showCustomSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Text(
              '无法撤销',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF1565C0),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}