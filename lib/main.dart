import 'dart:async'; // Для использования Timer
import 'package:flutter/material.dart';

void main() {
  runApp(const StopwatchApp());
}

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Секундомер Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StopwatchPage(),
    );
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  // Инициализация встроенного в Dart класса Stopwatch для точного отсчета
  final Stopwatch _stopwatch = Stopwatch();
  
  // Таймер для периодического обновления UI
  Timer? _timer;
  
  // Список для хранения времени кругов
  final List<String> _laps = [];

  // Метод для форматирования времени в строку MM:SS.mm
  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate();

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr.$hundredsStr";
  }

  // Запуск или пауза секундомера
  void _startStopTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel(); // Останавливаем обновление UI
    } else {
      _stopwatch.start();
      // Запускаем Timer для обновления UI каждые 30 мс
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        setState(() {
          // Вызываем setState, чтобы обновить отображаемое время
        });
      });
    }
    setState(() {}); // Обновляем состояние кнопки (Старт/Стоп)
  }

  // Сброс секундомера
  void _resetTimer() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    setState(() {
      _laps.clear(); // Очищаем список кругов
    });
  }

  // Добавление круга
  void _addLap() {
    // Добавляем только если таймер запущен или есть время на табло
    if (_stopwatch.elapsedMilliseconds > 0) {
      setState(() {
        String lapTime = _formatTime(_stopwatch.elapsedMilliseconds);
        // Вставляем в начало списка, чтобы новые круги были сверху
        _laps.insert(0, "Круг ${_laps.length + 1}: $lapTime");
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Обязательно отменяем таймер при закрытии экрана
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Текущее время для отображения
    String formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Секундомер'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
      ),
      body: Column(
        children: [
          // Блок с отображением времени
          Container(
            padding: const EdgeInsets.symmetric(vertical: 50),
            alignment: Alignment.center,
            child: Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()], // Моноширинные цифры (чтобы не прыгали)
              ),
            ),
          ),
          
          // Блок с кнопками управления
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Кнопка Сброс
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Сброс', style: TextStyle(color: Colors.red)),
                ),
                
                // Кнопка Старт/Стоп
                ElevatedButton(
                  onPressed: _startStopTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _stopwatch.isRunning ? Colors.orange.shade100 : Colors.green.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    _stopwatch.isRunning ? 'Стоп' : 'Старт',
                    style: TextStyle(
                      fontSize: 18,
                      color: _stopwatch.isRunning ? Colors.deepOrange : Colors.green[900],
                    ),
                  ),
                ),

                // Кнопка Круг
                ElevatedButton(
                  onPressed: _addLap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Круг', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("История кругов:", style: TextStyle(fontWeight: FontWeight.w500)),
          ),

          // Список кругов (ListView)
          Expanded(
            child: _laps.isEmpty
                ? const Center(
                    child: Text(
                      'Нет записанных кругов',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _laps.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: ListTile(
                          leading: const Icon(Icons.timer_outlined),
                          title: Text(
                            _laps[index],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}