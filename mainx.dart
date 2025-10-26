import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp()); // Cambiado el nombres de la app a MyApp
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SICA App', // Título de la aplicación
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Lista de páginas que se mostrarán en el cuerpo del Scaffold
  // El orden aquí debe coincidir con el orden de los BottomNavigationBarItem
  final List<Widget> _pages = [
    SexoPage(),
    PersonaPage(), // Nueva página para Personas
    Placeholder(), // Página "Acerca de" o cualquier otra que desees
  ];

  // Función que se llama cuando se toca un elemento del BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SICA - Registro")), // Título de la AppBar
      body: _pages[_selectedIndex], // Muestra la página seleccionada
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Sexo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Persona'), // Nuevo ítem para Persona
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Acerca de'),
        ],
        currentIndex: _selectedIndex, // Índice del ítem seleccionado actualmente
        onTap: _onItemTapped, // Callback cuando se toca un ítem
        selectedItemColor: Colors.blue, // Color del ítem seleccionado
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
      ),
    );
  }
}

// --- Clases de Modelo ---

// Modelo para los datos de Sexo
class Sexo {
  final String idsexo;
  final String nombre;

  Sexo({required this.idsexo, required this.nombre});

  factory Sexo.fromJson(Map<String, dynamic> json) {
    return Sexo(
      idsexo: json['idsexo'].toString(),
      nombre: json['nombre'],
    );
  }
}

// Modelo para los datos de Persona
class Persona {
  final String idpersona;
  final String nombres;
  final String apellidos;
  final String elsexo;
  final String elestadocivil;
  final String fechanacimiento; // Asumiendo que viene como String

  Persona({
    required this.idpersona,
    required this.nombres,
    required this.apellidos,
    required this.elsexo,
    required this.elestadocivil,
    required this.fechanacimiento,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      idpersona: json['idpersona'].toString(),
      nombres: json['nombres'] ?? 'N/A',
      apellidos: json['apellidos'] ?? 'N/A',
      elsexo: json['elsexo'] ?? 'N/A',
      elestadocivil: json['elestadocivil'] ?? 'N/A',
      fechanacimiento: json['fechanacimiento'] ?? 'N/A',
    );
  }
}

// --- Páginas de Contenido ---

// Página para mostrar la lista de Sexo
class SexoPage extends StatefulWidget {
  @override
  _SexoPageState createState() => _SexoPageState();
}

class _SexoPageState extends State<SexoPage> {
  List<Sexo> _sexoList = [];
  List<Sexo> _filteredSexoList = [];
  String _searchText = '';
  bool _isLoading = true; // Para mostrar un indicador de carga

  @override
  void initState() {
    super.initState();
    _fetchSexoData();
  }

  Future<void> _fetchSexoData() async {
    setState(() {
      _isLoading = true; // Inicia la carga
    });
    try {
      final response = await http.get(Uri.parse('https://educaysoft.org/ibm6b/app/controllers/SexoController.php?action=api'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _sexoList = data.map((item) => Sexo.fromJson(item)).toList();
          _filteredSexoList = _sexoList;
        });
      } else {
        throw Exception('Error al cargar datos de Sexo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener datos de Sexo: $e');
      // Podrías mostrar un mensaje de error al usuario aquí
    } finally {
      setState(() {
        _isLoading = false; // Finaliza la carga
      });
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _searchText = query;
      _filteredSexoList = _sexoList
          .where((item) =>
              item.nombre.toLowerCase().contains(query.toLowerCase()) ||
              item.idsexo.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _filterSearch,
            decoration: InputDecoration(
              labelText: 'Buscar Sexo',
              hintText: 'Ingrese nombres o ID',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        // Lista de registros
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator()) // Indicador de carga
              : _filteredSexoList.isEmpty
                  ? Center(child: Text("No hay datos de Sexo disponibles"))
                  : ListView.builder(
                      itemCount: _filteredSexoList.length,
                      itemBuilder: (context, index) {
                        final sexo = _filteredSexoList[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.people, color: Colors.blueAccent),
                            title: Text(sexo.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("ID: ${sexo.idsexo}"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
                            onTap: () {
                              // Acción al hacer tap en un elemento de sexo
                              print('Sexo seleccionado: ${sexo.nombre}');
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// Página para mostrar la lista de Persona
class PersonaPage extends StatefulWidget {
  @override
  _PersonaPageState createState() => _PersonaPageState();
}

class _PersonaPageState extends State<PersonaPage> {
  List<Persona> _personaList = [];
  List<Persona> _filteredPersonaList = [];
  String _searchText = '';
  bool _isLoading = true; // Para mostrar un indicador de carga

  @override
  void initState() {
    super.initState();
    _fetchPersonaData();
  }

  Future<void> _fetchPersonaData() async {
    setState(() {
      _isLoading = true; // Inicia la carga
    });
    try {
      final response = await http.get(Uri.parse('https://educaysoft.org/apple6b/app/controllers/PersonaController.php?action=api'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _personaList = data.map((item) => Persona.fromJson(item)).toList();
          _filteredPersonaList = _personaList;
        });
      } else {
        throw Exception('Error al cargar datos de Persona: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener datos de Persona: $e');
      // Podrías mostrar un mensaje de error al usuario aquí
    } finally {
      setState(() {
        _isLoading = false; // Finaliza la carga
      });
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _searchText = query;
      _filteredPersonaList = _personaList
          .where((item) =>
              item.nombres.toLowerCase().contains(query.toLowerCase()) ||
              item.apellidos.toLowerCase().contains(query.toLowerCase()) ||
              item.fechanacimiento.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _filterSearch,
            decoration: InputDecoration(
              labelText: 'Buscar Persona',
              hintText: 'Ingrese nombres, apellidos o cédula',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        // Lista de registros
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator()) // Indicador de carga
              : _filteredPersonaList.isEmpty
                  ? Center(child: Text("No hay datos de Persona disponibles"))
                  : ListView.builder(
                      itemCount: _filteredPersonaList.length,
                      itemBuilder: (context, index) {
                        final persona = _filteredPersonaList[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.person, color: Colors.green),
                            title: Text("${persona.nombres} ${persona.apellidos}", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Fechanacimiento: ${persona.fechanacimiento}"),
                                Text("TSexo: ${persona.elsexo}"),
                                Text("Estado Civil: ${persona.elestadocivil}"),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
                            onTap: () {
                              // Acción al hacer tap en un elemento de persona
                              print('Persona seleccionada: ${persona.nombres} ${persona.apellidos}');
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

