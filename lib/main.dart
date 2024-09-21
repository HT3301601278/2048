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
      title: '2048 游戏',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
    print('滑动检测到: $direction');
    print('滑动前的棋盘状态: ${_controller.board}');
    setState(() {
      _controller.move(direction);
    });
    print('滑动后的棋盘状态: ${_controller.board}');
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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('2048'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _buildScoreBoard(),
          SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  _handleSwipe(Direction.up);
                } else if (details.primaryVelocity! > 0) {
                  _handleSwipe(Direction.down);
                }
              },
              onHorizontalDragEnd: (details) {
                print('水平滑动检测到');
                if (details.primaryVelocity! < 0) {
                  print('滑动检测到: left');
                  _handleSwipe(Direction.left);
                } else if (details.primaryVelocity! > 0) {
                  print('滑动检测到: right');
                  _handleSwipe(Direction.right);
                }
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView.builder(
                  itemCount: 16,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    int value = _controller.board[index];
                    return GameTile(value: value);
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _controller.startGame();
              });
            },
            child: Text('重新开始'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle: TextStyle(fontSize: 18),
            ),
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
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(5),
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
}