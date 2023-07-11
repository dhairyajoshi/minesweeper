// ignore_for_file: must_be_immutable

import 'dart:collection';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/bloc/appbloc.dart';

class GameLoadingState extends AppState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GameLoadedState extends AppState {
  int rows, cols;
  List<List<String>> grid;
  List<List<bool>> revealed;
  bool gameover;
  GameLoadedState(
      this.gameover, this.grid, this.revealed, this.rows, this.cols);

  @override
  List<Object> get props => [gameover, grid, revealed];
}

class LoadGameEvent extends AppEvent {}

class ResetGameEvent extends AppEvent {}

class CellClickEvent extends AppEvent {
  int i, j;

  CellClickEvent(this.i, this.j);
}

class GameBloc extends Bloc<AppEvent, AppState> {
  int rows = 10, cols = 10;
  List<List<String>> grid = [];
  List<List<bool>> revealed = [];
  List<List<int>> dirs = [
    [0, 1],
    [0, -1],
    [1, 0],
    [-1, 0]
  ];
  bool gameover = false;
  final q = Queue<List<int>>();
  GameBloc() : super(GameLoadingState()) {
    on<LoadGameEvent>(
      (event, emit) {
        gameover = false;
        var tgrid = List.generate(rows, (_) => List.filled(cols, '0'));
        revealed = List.generate(rows, (_) => List.filled(cols, false));
        q.clear();
        for (int i = 0; i < rows; i++) {
          for (int j = 0; j < cols; j++) {
            tgrid[i][j] = (['M', ' ', ' ']..shuffle()).first;
          }
        }
        grid = tgrid;
        emit(GameLoadedState(gameover, grid, revealed, rows, cols));
      },
    );

    on<CellClickEvent>(
      (event, emit) {
        int i = event.i, j = event.j;

        if (grid[i][j] == 'M') {
          emit(GameLoadingState());
          revealed[i][j] = true;
          gameover = true;
          emit(GameLoadedState(gameover, grid, revealed, rows, cols));
          return;
        }

        if (revealed[i][j]) {
          emit(GameLoadedState(gameover, grid, revealed, rows, cols));
          return;
        }

        q.addLast([i, j]);
        revealed[i][j] = true;

        while (q.isNotEmpty) {
          int x = q.first[0], y = q.first[1];
          q.removeFirst();

          int cnt = 0;

          for (var dir in dirs) {
            int nx = x + dir[0], ny = y + dir[1];

            if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
              if (grid[nx][ny] == 'M') cnt++;
            }
          }

          if (cnt > 0) {
            grid[x][y] = '$cnt';
          } else {
            for (var dir in dirs) {
              int nx = x + dir[0], ny = y + dir[1];

              if (nx >= 0 &&
                  nx < rows &&
                  ny >= 0 &&
                  ny < cols &&
                  grid[nx][ny] == ' ' &&
                  !revealed[nx][ny]) {
                q.addLast([nx, ny]);
                revealed[nx][ny] = true;
              }
            }
          }
        }
        emit(GameLoadingState());

        emit(GameLoadedState(gameover, grid, revealed, rows, cols));
      },
    );

    on<ResetGameEvent>(
      (event, emit) {
        gameover = false;
        add(LoadGameEvent());
      },
    );
  }
}
