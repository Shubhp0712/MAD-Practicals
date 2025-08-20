import 'package:flutter/material.dart';

// ------------------ WasteBin Model ---------------------
class WasteBin {
  String binId;
  String wasteType; // organic, plastic, e-waste
  double capacityInKg;
  double currentLevelInKg;
  String zoneName;

  WasteBin({
    required this.binId,
    required this.wasteType,
    required this.capacityInKg,
    required this.currentLevelInKg,
    required this.zoneName,
  });

  void addWaste(double kg) {
    if (currentLevelInKg + kg <= capacityInKg) {
      currentLevelInKg += kg;
    } else {
      currentLevelInKg = capacityInKg;
    }
  }

  void emptyBin() {
    currentLevelInKg = 0;
  }

  double getFillPercentage() {
    return (currentLevelInKg / capacityInKg) * 100;
  }
}

// ------------------ WasteManagementSystem ---------------------
class WasteManagementSystem {
  List<WasteBin> bins = [];

  void addBin(WasteBin bin) {
    bins.add(bin);
  }

  Map<String, List<WasteBin>> getBinsGroupedByZone() {
    Map<String, List<WasteBin>> zones = {};
    for (var bin in bins) {
      zones.putIfAbsent(bin.zoneName, () => []).add(bin);
    }
    return zones;
  }

  Map<String, Map<String, double>> generateZoneReport() {
    var report = <String, Map<String, double>>{};
    var zones = getBinsGroupedByZone();

    for (var zoneEntry in zones.entries) {
      String zoneName = zoneEntry.key;
      List<WasteBin> zoneBins = zoneEntry.value;

      double totalWaste = zoneBins.fold(
        0,
        (sum, bin) => sum + bin.currentLevelInKg,
      );
      var typeAvgs = <String, double>{};

      var wasteTypeGroups = <String, List<WasteBin>>{};
      for (var bin in zoneBins) {
        wasteTypeGroups.putIfAbsent(bin.wasteType, () => []).add(bin);
      }

      for (var typeEntry in wasteTypeGroups.entries) {
        String wasteType = typeEntry.key;
        List<WasteBin> typeBins = typeEntry.value;
        double avgFill =
            typeBins.fold(0.0, (sum, bin) => sum + bin.getFillPercentage()) /
            typeBins.length;
        typeAvgs[wasteType] = avgFill;
      }

      report[zoneName] = {'totalWaste': totalWaste, ...typeAvgs};
    }

    return report;
  }

  String generatePrintableReport() {
    final buffer = StringBuffer();
    var report = generateZoneReport();

    buffer.writeln('Smart City Waste Report');
    buffer.writeln('=========================');

    for (var zoneEntry in report.entries) {
      buffer.writeln('Zone: ${zoneEntry.key}');
      buffer.writeln(
        '  Total Waste: ${zoneEntry.value['totalWaste']?.toStringAsFixed(2)} kg',
      );
      for (var entry in zoneEntry.value.entries) {
        if (entry.key != 'totalWaste') {
          buffer.writeln(
            '  Avg fill ${entry.key}: ${entry.value.toStringAsFixed(2)}%',
          );
        }
      }
      buffer.writeln('');
    }
    return buffer.toString();
  }
}

// ------------------ SmartWasteApp Widget ---------------------
class SmartWasteApp extends StatefulWidget {
  const SmartWasteApp({super.key});

  @override
  State<SmartWasteApp> createState() => _SmartWasteAppState();
}

class _SmartWasteAppState extends State<SmartWasteApp> {
  final WasteManagementSystem wms = WasteManagementSystem()
    ..addBin(
      WasteBin(
        binId: 'B1',
        wasteType: 'organic',
        capacityInKg: 100,
        currentLevelInKg: 50,
        zoneName: 'ZoneA',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B2',
        wasteType: 'plastic',
        capacityInKg: 80,
        currentLevelInKg: 75,
        zoneName: 'ZoneA',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B3',
        wasteType: 'e-waste',
        capacityInKg: 50,
        currentLevelInKg: 10,
        zoneName: 'ZoneA',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B4',
        wasteType: 'organic',
        capacityInKg: 100,
        currentLevelInKg: 95,
        zoneName: 'ZoneB',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B5',
        wasteType: 'plastic',
        capacityInKg: 70,
        currentLevelInKg: 65,
        zoneName: 'ZoneB',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B6',
        wasteType: 'e-waste',
        capacityInKg: 40,
        currentLevelInKg: 38,
        zoneName: 'ZoneB',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B7',
        wasteType: 'organic',
        capacityInKg: 90,
        currentLevelInKg: 88,
        zoneName: 'ZoneC',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B8',
        wasteType: 'plastic',
        capacityInKg: 60,
        currentLevelInKg: 20,
        zoneName: 'ZoneC',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B9',
        wasteType: 'e-waste',
        capacityInKg: 45,
        currentLevelInKg: 15,
        zoneName: 'ZoneC',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B10',
        wasteType: 'organic',
        capacityInKg: 80,
        currentLevelInKg: 75,
        zoneName: 'ZoneD',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B11',
        wasteType: 'plastic',
        capacityInKg: 85,
        currentLevelInKg: 83,
        zoneName: 'ZoneD',
      ),
    )
    ..addBin(
      WasteBin(
        binId: 'B12',
        wasteType: 'e-waste',
        capacityInKg: 55,
        currentLevelInKg: 54,
        zoneName: 'ZoneD',
      ),
    );

  @override
  Widget build(BuildContext context) {
    var zones = wms.getBinsGroupedByZone();
    var reports = wms.generateZoneReport();

    return MaterialApp(
      title: 'Smart City Waste Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Smart City Waste Management'),
          backgroundColor: Colors.green[700],
        ),
        body: ListView(
          children: [
            for (var zoneEntry in zones.entries)
              Card(
                margin: const EdgeInsets.all(10),
                elevation: 8,
                color: Colors.green[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.green.shade200, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🗺️ Zone: ${zoneEntry.key}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...zoneEntry.value.map(
                        (bin) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '🗑️ Bin ${bin.binId} (${bin.wasteType}) - ${bin.currentLevelInKg} kg',
                                  ),
                                ),
                                if (bin.getFillPercentage() > 90)
                                  const Icon(
                                    Icons.warning_amber,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                              ],
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: bin.getFillPercentage() / 100,
                                color: bin.getFillPercentage() > 90
                                    ? Colors.red
                                    : (bin.getFillPercentage() > 60
                                          ? Colors.orange
                                          : Colors.green),
                                backgroundColor: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            for (var bin in zoneEntry.value) {
                              if (bin.getFillPercentage() > 90) {
                                bin.emptyBin();
                              }
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Emptied bins >90% in ${zoneEntry.key}',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: const Text('Empty bins >90% full'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Divider(),
                      Text(
                        '📊 Zone Report:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Waste: ${reports[zoneEntry.key]!['totalWaste']?.toStringAsFixed(2)} kg',
                      ),
                      for (var entry in reports[zoneEntry.key]!.entries)
                        if (entry.key != 'totalWaste')
                          Text(
                            'Avg fill ${entry.key}: ${entry.value.toStringAsFixed(2)}%',
                          ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            String reportText = wms.generatePrintableReport();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('📋 Waste Management Report'),
                content: SingleChildScrollView(child: Text(reportText)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.print),
          label: const Text('Print Report'),
        ),
      ),
    );
  }
}
