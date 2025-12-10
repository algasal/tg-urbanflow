import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/station_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _statusMessage = "Iniciando...";
  Station? _nearestStation;
  Station? _selectedStation;
  String? _currentDirection;
  String? _oppositeDirection;
  int _directionIndex = 0;

  bool _isOnTrain = false;
  String? _trainDirection;
  Timer? _timer;
  String _etaMessage = "Buscando informações...";

  /// FastAPI Backend
  final String _backendUrl = 'http://localhost:8000';

  final Map<String, List<String>> lineDirections = {
    "L8" : ["Itapevi", "Julio Prestes"],
    "L9" : ["Varginha", "Osasco"],
  };

  @override
  void initState() {
    super.initState();
    _checkLocationAndSuggestStation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Consulta a API para verificar o próximo trem indo para a direção escolhida
  Future<List<dynamic>> _getNextTrain(String line, String stationCode) async {
    final uri = Uri.parse("$_backendUrl/proximo-trem?linha=$line&estacao=$stationCode&sentido=$_currentDirection");

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) {
        throw Exception("Erro: ${resp.body}");
      }

      return json.decode(resp.body);
    } catch (e) {
      throw Exception("Falha ao conectar: $e");
    }
  }

  /// Atualiza a as informações do trem consultando a api a cada x segundos
  void _startTrainUpdates(Station station) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (!_isOnTrain) _fetchNextTrain(station);
    });

    _fetchNextTrain(station);
  }

  Future<void> _fetchNextTrain(Station station) async {
  try {
    final data = await _getNextTrain(station.line, station.apiCode);

    // Get the list of trains
    final trains = data;

    if (trains == null || trains is! List || trains.isEmpty) {
      setState(() => _etaMessage = "Nenhuma previsão no momento.");
      return;
    }

    if (_directionIndex >= trains.length) {
      setState(() {
        _etaMessage = "Sem previsão no momento.";
      });
      return;
    }

    final selected = trains[_directionIndex];

    final int? minutes = selected["proximo_em"];
    final String? chegada = selected["hora_previsto_chegada"];
    final String status = selected["status"] ?? "";
    final String estacao_atual_cod = selected["estacao_origem_trem"] ?? "";
    final String estacao_atual_name = stationByCode[estacao_atual_cod]?.name ?? estacao_atual_cod;

    String msg = "";

    if (minutes != null) {
      msg = "Próximo trem em $minutes segundos\n"
            "Status: $status\n"
            "Trem atualmente em: $estacao_atual_name\n"
            "Chegada prevista: $chegada";
    } else {
      msg = "Sem previsão disponível.";
    }

    if (mounted) {
      setState(() => _etaMessage = msg);
    }

  } catch (e) {
    print(e);
    if (mounted) {
      setState(() => _etaMessage = "Erro ao ler dados do servidor.");
    }
  }
}


  /// Estação mais próxima com base na localização

  Future<void> _checkLocationAndSuggestStation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Obtendo sua localização...";
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Permissão de localização negada.");
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Localização permanentemente negada.");
      }

      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _findNearestStation(pos);

    } catch (e) {
      setState(() => _statusMessage = "Erro: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _findNearestStation(Position pos) {
    Station? nearest;
    double minDist = double.infinity;

    for (final st in mockStations) {
      double d = Geolocator.distanceBetween(pos.latitude, pos.longitude, st.latitude, st.longitude);
      if (d < minDist) {
        minDist = d;
        nearest = st;
      }
    }

    if (nearest != null && minDist < 1000) {
      _nearestStation = nearest;
      _statusMessage = "Localização obtida!";
      _showSuggestionDialog(nearest, minDist);
    } else {
      _statusMessage = "Você não está próximo a nenhuma estação.";
    }
  }

  void _showSuggestionDialog(Station st, double dist) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Estação Detectada"),
        content: Text("Você está a ~${dist.toStringAsFixed(0)}m da estação ${st.name}."),
        actions: [
          TextButton(
            child: const Text("Escolher outra"),
            onPressed: () {
              Navigator.pop(context);
              _showManualStationSelector();
            },
          ),
          ElevatedButton(
            child: const Text("Sim, estou aqui"),
            onPressed: () {
              Navigator.pop(context);
              _confirmStation(st);
            },
          ),
        ],
      ),
    );
  }

  /// Escolha manual da estação desejada
  void _showManualStationSelector() {
  showModalBottomSheet(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Text("Selecione a Linha", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        ListTile(
          leading: const Icon(Icons.train),
          title: const Text("Linha 8 - Diamante"),
          onTap: () {
            Navigator.pop(context);
            _showStationsByLine("L8");
          },
        ),

        ListTile(
          leading: const Icon(Icons.train),
          title: const Text("Linha 9 - Esmeralda"),
          onTap: () {
            Navigator.pop(context);
            _showStationsByLine("L9");
          },
        ),
      ],
    ),
  );
}

void _showStationsByLine(String line) {
  final stations = mockStations.where((s) => s.line == line).toList();

  showModalBottomSheet(
    context: context,
    builder: (_) => ListView(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Estações da $line",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),

        ...stations.map((st) => ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(st.name),
          subtitle: Text("Código: ${st.apiCode}"),
          onTap: () {
            Navigator.pop(context);
            _confirmStation(st);
          },
        )),
      ],
    ),
  );
}



  void _confirmStation(Station station) {
    final directions = lineDirections[station.line];

    if (directions == null || directions.length != 2) {
      setState(() {
        _selectedStation = station;
        _isOnTrain = false;
      });
      _startTrainUpdates(station);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Selecione o sentido"),
        content: Text("Para qual direção você está indo?"),
        actions: [
          TextButton(
            child: Text(directions[0]),
            onPressed: () {
              Navigator.pop(context);
              _setDirectionAndStart(station, directions[0], directions[1]);
            },
          ),
          ElevatedButton(
            child: Text(directions[1]),
            onPressed: () {
              Navigator.pop(context);
              _setDirectionAndStart(station, directions[1], directions[0]);
            },
          ),
        ],
      ),
    );
  }

  void _setDirectionAndStart(Station st, String dir, String opposite) {
  setState(() {
    _selectedStation = st;
    _currentDirection = dir;
    _oppositeDirection = opposite;
    _directionIndex = (dir == lineDirections[st.line]![0]) ? 0 : 1;
    _isOnTrain = false;
    _etaMessage = "Buscando informações...";
  });

  _startTrainUpdates(st);
}



  /// UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UrbanFlow"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _checkLocationAndSuggestStation)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_statusMessage ?? "")
                  ],
                ),
              )
            : _selectedStation == null
                ? _buildStationSelector()
                : _buildDashboard(),
      ),
    );
  }

  Widget _buildStationSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_statusMessage ?? "Selecione uma estação."),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text("Selecionar Estação Manualmente"),
            onPressed: _showManualStationSelector,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return _isOnTrain ? _buildOnTrainView() : _buildWaitingView();
  }

  Widget _buildWaitingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("Você está na estação:", style: TextStyle(fontSize: 16)),
                Text(
                  "${_selectedStation!.name} (${_selectedStation!.line})",
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_currentDirection != null)
                  TextButton.icon(
                    icon: const Icon(Icons.swap_vert),
                    label: Text("Sentido: $_currentDirection"),
                    onPressed: () {
                      setState(() {
                        final temp = _currentDirection;
                        _currentDirection = _oppositeDirection;
                        _oppositeDirection = temp;
                        _directionIndex = (_directionIndex == 0) ? 1 : 0;
                        _etaMessage = "Carregando informações...";
                      });

                      if (_selectedStation != null) {
                        _startTrainUpdates(_selectedStation!);
                      }
                    }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              Text(_etaMessage, style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.directions_train, color: Colors.white),
          label: const Text("EMBARQUEI NO TREM", style: TextStyle(fontSize: 18)),
          onPressed: _showDirectionDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        TextButton(
          child: const Text("Mudar de estação"),
          onPressed: _showManualStationSelector,
        ),
      ],
    );
  }

  void _showDirectionDialog() {
    final directions = lineDirections[_selectedStation!.line];

    if (directions == null || directions.length != 2) {
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sentido do Trem"),
        content: const Text("Para qual direção você está indo?"),
        actions: [
          TextButton(
            child: Text(directions[0]),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isOnTrain = true);
            },
          ),
          ElevatedButton(
            child: Text(directions[1]),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isOnTrain = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOnTrainView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.train, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text("Você está em trânsito!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 50),
        ElevatedButton(
          child: const Text("DESEMBARCAR / FINALIZAR VIAGEM"),
          onPressed: () {
            setState(() {
              _isOnTrain = false;
              if (_selectedStation != null) {
                _startTrainUpdates(_selectedStation!);
              }
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ],
    );
  }
}
