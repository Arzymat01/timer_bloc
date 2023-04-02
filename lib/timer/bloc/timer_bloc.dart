import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:timer_bloc/app/ticer.dart';
part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  static const int _duration = 60;
  final Ticker _ticker;
  StreamSubscription<int>? _tickerSubscription;
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<_TimerTicked>(_onTiced);
    on<TimerReset>(_onResed);
  }

  Future<void> close() {
    _tickerSubscription?.cancel();
    return close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: event.duration).listen(
          (duration) => add(
            _TimerTicked(duration: duration),
          ),
        );
  }

  void _onTiced(_TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : const TimerRunComplete(),
    );
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(
        TimerRunPause(state.duration),
      );
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.resume();
      emit(
        TimerRunPause(state.duration),
      );
    }
  }

  void _onResed(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(
      const TimerInitial(_duration),
    );
  }
}
