import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_bloc/app/ticer.dart';
import 'package:timer_bloc/timer/bloc/timer_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerBloc(ticker: Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Stack(
        children: [
          const Bacround(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(child: TimerText()),
              ),
              Actions()
            ],
          )
        ],
      ),
    );
  }
}

class Bacround extends StatelessWidget {
  const Bacround({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade500,
          ],
        ),
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      '$minutesStr:$secondsStr',
      style: Theme.of(context).textTheme.headline1,
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (state is TimerInitial) ...[
              FloatingActionButton(
                onPressed: () => context
                    .read<TimerBloc>()
                    .add(TimerStarted(duration: state.duration)),
                child: const Icon(Icons.play_arrow),
              ),
            ],
            if (state is TimerRunInProgress) ...[
              FloatingActionButton(
                child: const Icon(Icons.pause),
                onPressed: () => context.read<TimerBloc>().add(
                      const TimerPaused(),
                    ),
              ),
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () => context.read<TimerBloc>().add(
                      const TimerReset(),
                    ),
              ),
            ],
            if (state is TimerRunPause) ...[
              FloatingActionButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () => context.read<TimerBloc>().add(
                      const TimerResumed(),
                    ),
              ),
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () => context.read<TimerBloc>().add(
                      const TimerReset(),
                    ),
              ),
            ],
            if (state is TimerRunComplete) ...[
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () => context.read<TimerBloc>().add(
                      const TimerReset(),
                    ),
              ),
            ],
          ],
        );
      },
    );
  }
}
