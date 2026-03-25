import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateProvider()),
      ],
      child: const SuperTicTacToeApp(),
    ),
  );
}

class SuperTicTacToeApp extends StatelessWidget {
  const SuperTicTacToeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Tic-Tac-Toe',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromRGBO(2, 2, 48, 1),
        primarySwatch: Colors.deepPurple,
        fontFamily: 'monospace',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Super Tic-Tac-Toe',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(76, 29, 149, 1), // violet-950
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.white,
            height: 4.0,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Flex(
                direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const GameBoard(),
                  const SizedBox(height: 32, width: 32),
                  const GameControls(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: SizedBox(
            width: _getBoardSize(context),
            height: _getBoardSize(context),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 9,
              itemBuilder: (context, outerIndex) {
                return OuterGrid(outerIndex: outerIndex);
              },
            ),
          ),
        );
      },
    );
  }

  double _getBoardSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return 600;
    if (width > 600) return 480;
    return width - 40; // Full width with some padding
  }
}

class OuterGrid extends StatelessWidget {
  final int outerIndex;

  const OuterGrid({Key? key, required this.outerIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final isSelected = gameState.selectedOuterIndex == outerIndex;
        final isFreeMove = gameState.isFreeMove();
        final outerWinner = gameState.outerGrid[outerIndex];

        bool canPlay = false;
        if (outerWinner == Player.none) {
          if (isFreeMove || isSelected) {
            canPlay = true;
          }
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: outerWinner == Player.o || outerWinner == Player.x
                ? Colors.green.shade800
                : outerWinner == Player.draw
                    ? Colors.grey.shade800
                    : (canPlay ? const Color.fromRGBO(89, 89, 155, 1) : const Color.fromRGBO(2, 2, 48, 1)),
            border: Border.all(
              color: canPlay ? Colors.redAccent.shade100 : Colors.white24,
              width: canPlay ? 3 : 1,
            ),
          ),
          child: Stack(
            children: [
              // The Inner Grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 9,
                itemBuilder: (context, innerIndex) {
                  return InnerBox(outerIndex: outerIndex, innerIndex: innerIndex);
                },
              ),
              // The Large Winner Overlay
              if (outerWinner != Player.none)
                Center(
                  child: Text(
                    outerWinner == Player.o ? '⭘' : outerWinner == Player.x ? '✘' : '⦻',
                    style: TextStyle(
                      fontSize: _getBoardSize(context) / 6,
                      fontWeight: FontWeight.bold,
                      color: outerWinner == Player.draw ? Colors.red : Colors.yellowAccent.shade100,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _getBoardSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return 600;
    if (width > 600) return 480;
    return width - 40;
  }
}

class InnerBox extends StatelessWidget {
  final int outerIndex;
  final int innerIndex;

  const InnerBox({Key? key, required this.outerIndex, required this.innerIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final player = gameState.innerGrids[outerIndex][innerIndex];
        final isOuterWon = gameState.outerGrid[outerIndex] != Player.none;

        return GestureDetector(
          onTap: () {
            if (!isOuterWon && player == Player.none) {
              gameState.playMove(outerIndex, innerIndex);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54, width: 1),
              color: Colors.transparent,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  player == Player.o ? '⭘' : player == Player.x ? '✘' : '',
                  key: ValueKey<Player>(player),
                  style: TextStyle(
                    fontSize: _getInnerFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent.shade100,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getInnerFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return 36;
    if (width > 600) return 28;
    return 20;
  }
}

class GameControls extends StatelessWidget {
  const GameControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        String statusText = '';
        if (gameState.winner != Player.none) {
          statusText = gameState.winner == Player.o ? '⭘ Wins!' : '✘ Wins!';
        } else if (gameState.isDraw) {
          statusText = 'Draw!';
        } else if (gameState.isFreeMove()) {
          statusText = 'Free Move! ${gameState.turnO ? '⭘' : '✘'}\'s Turn';
        } else {
          statusText = '${gameState.turnO ? '⭘' : '✘'}\'s Turn';
        }

        return Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  statusText,
                  key: ValueKey<String>(statusText),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(30, 41, 59, 1), // slate-800
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color.fromRGBO(130, 130, 231, 1), width: 3),
                  ),
                  elevation: 5,
                  shadowColor: const Color.fromRGBO(167, 139, 250, 1), // violet-400
                ),
                onPressed: () {
                  gameState.resetGame();
                },
                child: const Text(
                  'Reset Game',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  _showRulesBottomSheet(context);
                },
                child: const Text(
                  'How to Play?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRulesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(76, 29, 149, 1), // violet-950
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Center(
                    child: Text(
                      'How to Play',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Objective',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Win by claiming three consecutive outer boxes (horizontally, vertically, or diagonally) on the large 3x3 grid. Each move inside an inner grid dictates the next grid for your opponent, adding a strategic twist to traditional Tic-Tac-Toe.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Rules',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Players take turns placing their mark (⭘ or ✘) in one of the smaller boxes within the larger grid.\n'
                      '• The position of your play in the small grid determines which large grid square your opponent must play in next.\n'
                      '• Win a small grid by getting three in a row within it. This claims that square in the larger grid.\n'
                      '• If your opponent sends you to a grid that\'s already won or full, you can play in any open grid (Free Move).\n'
                      '• Win the game by claiming three large grid squares in a row.\n'
                      '• The game ends in a draw if all squares are filled without a winner.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
