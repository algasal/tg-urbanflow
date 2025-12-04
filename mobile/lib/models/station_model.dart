class Station {
  final String id;        // local ID (UI only)
  final String name;      // station display name
  final String apiCode;   // official Próximo Trem station code
  final String line;      // L8 or L9
  final double latitude;
  final double longitude;

  Station({
    required this.id,
    required this.name,
    required this.apiCode,
    required this.line,
    required this.latitude,
    required this.longitude,
  });
}

// Linha 8 – Diamante
final List<Station> mockStations = [
  Station(id: '1', name: 'Júlio Prestes', apiCode: 'JPR', line: 'L8', latitude: -23.5356, longitude: -46.6457),
  Station(id: '2', name: 'Palmeiras-Barra Funda', apiCode: 'BFU', line: 'L8', latitude: -23.5265, longitude: -46.6642),
  Station(id: '3', name: 'Lapa', apiCode: 'LAB', line: 'L8', latitude: -23.5222, longitude: -46.7025),
  Station(id: '4', name: 'Domingos de Moraes', apiCode: 'DMO', line: 'L8', latitude: -23.5246, longitude: -46.7219),
  Station(id: '5', name: 'Imperatriz Leopoldina', apiCode: 'ILE', line: 'L8', latitude: -23.5255, longitude: -46.7369),
  Station(id: '6', name: 'Presidente Altino', apiCode: 'PAL', line: 'L8', latitude: -23.5283, longitude: -46.7562),
  Station(id: '7', name: 'Osasco', apiCode: 'OSA', line: 'L8', latitude: -23.5323, longitude: -46.7770),
  Station(id: '8', name: 'Comandante Sampaio', apiCode: 'CSA', line: 'L8', latitude: -23.5297, longitude: -46.7915),
  Station(id: '9', name: 'Quitaúna', apiCode: 'QTU', line: 'L8', latitude: -23.5276, longitude: -46.8045),
  Station(id: '10', name: 'General Miguel Costa', apiCode: 'GMC', line: 'L8', latitude: -23.5246, longitude: -46.8188),
  Station(id: '11', name: 'Carapicuíba', apiCode: 'CPB', line: 'L8', latitude: -23.5228, longitude: -46.8360),
  Station(id: '12', name: 'Santa Terezinha', apiCode: 'STE', line: 'L8', latitude: -23.5186, longitude: -46.8465),
  Station(id: '13', name: 'Antônio João', apiCode: 'AJO', line: 'L8', latitude: -23.5118, longitude: -46.8580),
  Station(id: '14', name: 'Barueri', apiCode: 'BRU', line: 'L8', latitude: -23.5132, longitude: -46.8770),
  Station(id: '16', name: 'Jardim Belval', apiCode: 'JBE', line: 'L8', latitude: -23.5218, longitude: -46.8885),
  Station(id: '17', name: 'Jardim Silveira', apiCode: 'JSI', line: 'L8', latitude: -23.5218, longitude: -46.8885),
  Station(id: '18', name: 'Jandira', apiCode: 'JDI', line: 'L8', latitude: -23.5290, longitude: -46.9030),
  Station(id: '19', name: 'Sagrado Coração', apiCode: 'SCO', line: 'L8', latitude: -23.5475, longitude: -46.9320),
  Station(id: '20', name: 'Engenheiro Cardoso', apiCode: 'ECD', line: 'L8', latitude: -23.5475, longitude: -46.9320),
  Station(id: '21', name: 'Itapevi', apiCode: 'IPV', line: 'L8', latitude: -23.5475, longitude: -46.9320),
  Station(id: '22', name: 'Santa Rita', apiCode: 'SRT', line: 'L8', latitude: -23.5475, longitude: -46.9320),
  Station(id: '23', name: 'Amador Bueno', apiCode: 'AMB', line: 'L8', latitude: -23.5475, longitude: -46.9320),
  Station(id: '24', name: 'Ambuitá', apiCode: 'ABU', line: 'L8', latitude: -23.5475, longitude: -46.9320),

  // Linha 9 – Esmeralda
  Station(id: '25', name: 'Varginha', apiCode: 'VAG', line: 'L9', latitude: -23.7239, longitude: -46.6964),
  Station(id: '26', name: 'Bruno Covas - Mendes / Vila Natal', apiCode: 'MVN', line: 'L9', latitude: -23.7085, longitude: -46.6905),
  Station(id: '27', name: 'Grajaú', apiCode: 'GRA', line: 'L9', latitude: -23.6975, longitude: -46.6913),
  Station(id: '28', name: 'Interlagos', apiCode: 'INT', line: 'L9', latitude: -23.6814, longitude: -46.6890),
  Station(id: '29', name: 'Autódromo', apiCode: 'AUT', line: 'L9', latitude: -23.6549, longitude: -46.7018),
  Station(id: '30', name: 'Jurubatuba', apiCode: 'JUR', line: 'L9', latitude: -23.6503, longitude: -46.7218),
  Station(id: '31', name: 'Socorro', apiCode: 'SOC', line: 'L9', latitude: -23.6437, longitude: -46.7396),
  Station(id: '32', name: 'Santo Amaro', apiCode: 'SAM', line: 'L9', latitude: -23.6380, longitude: -46.7439),
  Station(id: '33', name: 'Granja Julieta', apiCode: 'GJT', line: 'L9', latitude: -23.6308, longitude: -46.7322),
  Station(id: '34', name: 'Morumbi', apiCode: 'MRB', line: 'L9', latitude: -23.6102, longitude: -46.6971),
  Station(id: '35', name: 'Berrini', apiCode: 'BRR', line: 'L9', latitude: -23.6103, longitude: -46.6944),
  Station(id: '36', name: 'Vila Olímpia', apiCode: 'VOL', line: 'L9', latitude: -23.5951, longitude: -46.6871),
  Station(id: '37', name: 'Cidade Jardim', apiCode: 'CJD', line: 'L9', latitude: -23.5840, longitude: -46.6860),
  Station(id: '38', name: 'Hebraica - Rebouças', apiCode: 'HBR', line: 'L9', latitude: -23.5721, longitude: -46.6856),
  Station(id: '39', name: 'Pinheiros', apiCode: 'PIN', line: 'L9', latitude: -23.5670, longitude: -46.6958),
  Station(id: '40', name: 'Cidade Universitária', apiCode: 'USP', line: 'L9', latitude: -23.5610, longitude: -46.7287),
  Station(id: '41', name: 'Villa-Lobos / Jaguaré', apiCode: 'JAG', line: 'L9', latitude: -23.5502, longitude: -46.7365),
  Station(id: '42', name: 'Ceasa', apiCode: 'CEA', line: 'L9', latitude: -23.5369, longitude: -46.7432),
  Station(id: '43', name: 'João Dias', apiCode: 'JOD', line: 'L9', latitude: -23.6225, longitude: -46.7388),
  Station(id: '44', name: 'Presidente Altino', apiCode: 'PAL', line: 'L9', latitude: -23.5290, longitude: -46.7565),
  Station(id: '45', name: 'Osasco', apiCode: 'OSA', line: 'L9', latitude: -23.5323, longitude: -46.7770),
];

final Map<String, Station> stationByCode = {
  for (final s in mockStations) s.apiCode: s
};