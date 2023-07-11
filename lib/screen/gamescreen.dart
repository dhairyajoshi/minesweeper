// ignore_for_file: prefer_const_constructors

import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/bloc/appbloc.dart';
import 'package:minesweeper/bloc/gamebloc.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => GameBloc()..add(LoadGameEvent()),
        child: BlocBuilder<GameBloc, AppState>(
          builder: (context, state) {
            if (state is GameLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is GameLoadedState) {
              return Container(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Center(
                        child: Container(
                          child: Text(
                            'Minesweeper',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Container(
                        // color: Colors.green,
                        child: ListView.builder(
                            // shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: state.rows,
                            itemBuilder: ((context, index) {
                              return Center(
                                  child: GridRow(context, state, index));
                            })),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        // color: Colors.black,
                        child: state.gameover
                            ? Column(
                                children: [
                                  Center(
                                    child: Text(
                                      'Game Over',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 30),
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        BlocProvider.of<GameBloc>(context)
                                            .add(ResetGameEvent());
                                      },
                                      child: Text('Reset'))
                                ],
                              )
                            : SizedBox.shrink(),
                      ),
                    )
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class GridRow extends StatelessWidget {
  GridRow(this.ctx, this.state, this.rowno, {super.key});
  int rowno;
  GameLoadedState state;
  BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height / 15;
    double w = MediaQuery.of(context).size.width / 12;
    return Container(
      // width: w,
      height: h,
      decoration: BoxDecoration(
          // border: Border.all(color: Colors.black, width: 1),

          ),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: state.cols,
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            return GestureDetector(
              onTap: () {
                if (!state.gameover) {
                  BlocProvider.of<GameBloc>(ctx)
                      .add(CellClickEvent(rowno, index));
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width < 493 ? w : h,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  color: state.revealed[rowno][index]
                      ? state.grid[rowno][index] == 'M'
                          ? Colors.red
                          : Color.fromARGB(255, 136, 244, 140)
                      : Colors.white,
                ),
                // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: state.revealed[rowno][index]
                    ? state.grid[rowno][index] == 'M'
                        ? Center(child: Icon(Icons.circle))
                        : Center(child: Text(state.grid[rowno][index]))
                    : Text(''),
              ),
            );
          })),
    );
  }
}
