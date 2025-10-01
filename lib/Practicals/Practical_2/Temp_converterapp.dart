import 'package:flutter/material.dart';

class TempConverterapp extends StatefulWidget {
  const TempConverterapp({super.key});

  @override
  State<TempConverterapp> createState() => _TempConverterappState();
}

class _TempConverterappState extends State<TempConverterapp> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  String _fromUnit = 'Celsius';
  String _toUnit = 'Fahrenheit';

  final List<String> _units = ['Celsius', 'Fahrenheit', 'Kelvin'];

  void _convertTemperature() {
    final double? input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() {
        _result = 'Enter a valid number';
      });
      return;
    }

    double valueInCelsius;
    switch (_fromUnit) {
      case 'Fahrenheit':
        valueInCelsius = (input - 32) * 5 / 9;
        break;
      case 'Kelvin':
        valueInCelsius = input - 273.15;
        break;
      default:
        valueInCelsius = input;
    }

    double converted;
    String symbol;
    
    switch (_toUnit) {
      case 'Fahrenheit':
        converted = (valueInCelsius * 9 / 5) + 32;
        symbol = '°F';
        break;
      case 'Kelvin':
        converted = valueInCelsius + 273.15;
        symbol = 'K';
        break;
      default:
        converted = valueInCelsius;
        symbol = '°C';
    }

    setState(() {
      _result = '${converted.toStringAsFixed(2)} $symbol';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 200 : 16,
                    vertical: isDesktop ? 80 : 16,
                  ),
                  child: Center(
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 500 : double.infinity,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.thermostat, size: isDesktop ? 64 : 48, color: Color(0xFF2193b0)),
                              SizedBox(height: 8),
                              Text(
                                'Temperature Converter',
                                style: TextStyle(
                                  fontSize: isDesktop ? 32 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2193b0),
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isDesktop ? 32 : 24),
                              if (screenWidth < 400)
                                Column(
                                  children: [
                                    _buildUnitSelector('From', _fromUnit, (value) {
                                      setState(() {
                                        _fromUnit = value!;
                                      });
                                    }),
                                    const SizedBox(height: 12),
                                    _buildSwapButton(),
                                    const SizedBox(height: 12),
                                    _buildUnitSelector('To', _toUnit, (value) {
                                      setState(() {
                                        _toUnit = value!;
                                      });
                                    }),
                                  ],
                                )
                              else
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildUnitSelector('From', _fromUnit, (value) {
                                          setState(() {
                                            _fromUnit = value!;
                                          });
                                        }),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildSwapButton(),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: _buildUnitSelector('To', _toUnit, (value) {
                                          setState(() {
                                            _toUnit = value!;
                                          });
                                        }),
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(height: isDesktop ? 28 : 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _inputController,
                                  decoration: InputDecoration(
                                    labelText: 'Enter value in $_fromUnit',
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(
                                      Icons.thermostat,
                                      color: Color(0xFF2193b0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 16,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: isDesktop ? 18 : 16),
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.sync_alt, color: Colors.white),
                                  label: Text(
                                    'Convert',
                                    style: TextStyle(
                                        fontSize: isDesktop ? 18 : 16,
                                        color: Colors.white
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: const Color(0xFF2193b0),
                                  ),
                                  onPressed: _convertTemperature,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 32 : 24),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _result.isEmpty ? 'Result will appear here' : _result,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 28 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2193b0),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        );
    }

  Widget _buildUnitSelector(String label, String value, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: const Color(0xFFE3F2FD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF2193b0),
          ),
          items: _units
              .map(
                (unit) => DropdownMenuItem(
              value: unit,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    unit == 'Celsius'
                        ? Icons.ac_unit
                        : unit == 'Fahrenheit'
                        ? Icons.wb_sunny
                        : Icons.thermostat,
                    color: const Color(0xFF2193b0),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      unit,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSwapButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          setState(() {
            final temp = _fromUnit;
            _fromUnit = _toUnit;
            _toUnit = temp;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.swap_horiz,
            color: Color(0xFF2193b0),
            size: 24,
          ),
        ),
      ),
    );
  }
}