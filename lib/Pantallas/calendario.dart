import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:syncfusion_flutter_calendar/calendar.dart";
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class calendar extends StatefulWidget {
  const calendar({super.key, required this.titulo});

  final String titulo;

  @override
  State<calendar> createState() => _calendarState();
}

class _calendarState extends State<calendar> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController _nombreEvento = TextEditingController();
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(hours: 1));
  bool _todoElDia = false;
  Color _color = Colors.blue;
  bool _cargando = true;

  final List<Map> _eventos = [];

  void _resetForm() {
    _nombreEvento.clear();
    _fechaInicio = DateTime.now();
    _fechaFin = DateTime.now().add(const Duration(hours: 1));
    _todoElDia = false;
    _color = Colors.blue;
  }

  void _aniadirEvento() {
    _resetForm();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              elevation: 50,
              backgroundColor: Colors.white,
              shadowColor: Colors.pink,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Añadir evento:", style: TextStyle(fontSize: 30)),
                      const SizedBox(height: 5),

                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: const InputDecoration(labelText: "Nombre evento"),
                          controller: _nombreEvento,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Column(
                        children: [
                          MaterialButton(
                            color: Colors.blue,
                            child: Text(
                              "Inicio: ${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}  ${_fechaInicio.hour}:${_fechaInicio.minute.toString().padLeft(2,'0')}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate: _fechaInicio,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (fecha != null && context.mounted) {
                                final hora = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_fechaInicio),
                                );
                                if (hora != null) {
                                  setStateDialog(() {
                                    _fechaInicio = DateTime(
                                      fecha.year, fecha.month, fecha.day,
                                      hora.hour, hora.minute,
                                    );
                                    if (_fechaInicio.isAfter(_fechaFin)) {
                                      _fechaFin = _fechaInicio.add(const Duration(hours: 1));
                                    }
                                  });
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 5),
                          MaterialButton(
                            color: Colors.blue,
                            child: Text(
                              "Fin: ${_fechaFin.day}/${_fechaFin.month}/${_fechaFin.year}  ${_fechaFin.hour}:${_fechaFin.minute.toString().padLeft(2,'0')}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate: _fechaFin,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (fecha != null && context.mounted) {
                                final hora = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_fechaFin),
                                );
                                if (hora != null) {
                                  setStateDialog(() {
                                    _fechaFin = DateTime(
                                      fecha.year, fecha.month, fecha.day,
                                      hora.hour, hora.minute,
                                    );
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      MaterialButton(
                        color: _color,
                        child: const Text("Seleccionar color", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Elige un color"),
                                content: BlockPicker(
                                  pickerColor: _color,
                                  onColorChanged: (color) {
                                    setStateDialog(() => _color = color);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Todo el día: "),
                          Checkbox(
                            value: _todoElDia,
                            onChanged: (value) {
                              setStateDialog(() => _todoElDia = value ?? false);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      MaterialButton(
                        onPressed: () {
                          if (_nombreEvento.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Escribe un nombre para el evento')),
                            );
                            return;
                          }
                          if (_fechaFin.isBefore(_fechaInicio)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('La fecha de fin debe ser después del inicio')),
                            );
                            return;
                          }
                          Map<String, dynamic> evento = {
                            "Nombre": _nombreEvento.text.trim(),
                            "TodoElDia": _todoElDia,
                            "FechaInicio": _fechaInicio,
                            "FechaFin": _fechaFin,
                            "Color": _color.value,
                          };
                          _escribirEventoNube(evento);
                          Navigator.of(context).pop();
                        },
                        color: Colors.green,
                        child: const Text("Guardar", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _leeBase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> docs = await db.collection("eventos").get();
      for (var doc in docs.docs) {
        Map<String, dynamic> aux = {
          "Nombre": doc.get("Nombre"),
          "FechaInicio": (doc.get("FechaInicio") as Timestamp).toDate(),
          "FechaFin": (doc.get("FechaFin") as Timestamp).toDate(),
          "Color": Color(doc.get("Color")),
          "TodoElDia": doc.get("TodoElDia"),
        };
        if (mounted) setState(() => _eventos.add(aux));
      }
    } catch (e) {
      debugPrint("Error leyendo base: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _escribirEventoNube(Map<String, dynamic> evento) async {
    try {
      await db.collection("eventos").doc(evento["Nombre"]).set({
        "Nombre": evento["Nombre"],
        "FechaInicio": Timestamp.fromDate(evento["FechaInicio"]),
        "FechaFin": Timestamp.fromDate(evento["FechaFin"]),
        "Color": evento["Color"],
        "TodoElDia": evento["TodoElDia"],
      });
      if (mounted) {
        setState(() {
          _eventos.add({
            "Nombre": evento["Nombre"],
            "FechaInicio": evento["FechaInicio"],
            "FechaFin": evento["FechaFin"],
            "Color": Color(evento["Color"]),
            "TodoElDia": evento["TodoElDia"],
          });
        });
      }
    } catch (e) {
      debugPrint("Error al escribir evento: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _leeBase();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: MeetingDataSource(_getDataSource(_eventos)),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _aniadirEvento,
        tooltip: "Añadir evento",
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Meeting> _getDataSource(List<Map> eventos) {
    return eventos.map((e) => Meeting(
      e["Nombre"],
      e["FechaInicio"],
      e["FechaFin"],
      e["Color"],
      e["TodoElDia"],
    )).toList();
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override DateTime getStartTime(int index) => _data(index).from;
  @override DateTime getEndTime(int index) => _data(index).to;
  @override String getSubject(int index) => _data(index).eventName;
  @override Color getColor(int index) => _data(index).background;
  @override bool isAllDay(int index) => _data(index).isAllDay;

  Meeting _data(int index) => appointments![index] as Meeting;
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}