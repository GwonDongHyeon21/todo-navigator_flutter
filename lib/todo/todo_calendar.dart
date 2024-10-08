import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_flutter/todo/todo_content+navigator.dart';
import 'package:todo_flutter/provider/todo_provider.dart';
import 'package:todo_flutter/todo/todo_add.dart';

class TodoCalendar extends StatefulWidget {
  const TodoCalendar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoCalendarState createState() => _TodoCalendarState();
}

class _TodoCalendarState extends State<TodoCalendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    //todo 리스트 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('todo 달력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(10),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              locale: 'ko_KR',
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, _) {
                  final todoCount =
                      Provider.of<TodoProvider>(context).getTodoCount(date);
                  if (todoCount > 0) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '$todoCount',
                            style: const TextStyle().copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                defaultBuilder: (context, date, _) {
                  final todoCount =
                      Provider.of<TodoProvider>(context).getTodoCount(date);
                  if (todoCount > 0) {
                    return Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, todoProvider, child) {
                final todos = todoProvider.todos[_selectedDay] ?? [];
                if (todos.isEmpty) {
                  return const Center(
                    child: Text(
                      '할 일이 없습니다.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      leading: Checkbox(
                        value: todo.isDone,
                        onChanged: (value) {
                          todoProvider.checkTodoDone(_selectedDay, index);
                        },
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration:
                              todo.isDone ? TextDecoration.lineThrough : null,
                          color: todo.isDone ? Colors.grey : null,
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: MapNavigator(
                                  index: index,
                                  title: todo.title,
                                  date: todo.date,
                                  startLocation: todo.startLocation,
                                  endLocation: todo.endLocation,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Divider(thickness: 2),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_rounded,
              color: Colors.blue,
            ),
            iconSize: 50,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: TodoAdd(selectedDay: _selectedDay),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('체크된 할 일들을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Provider.of<TodoProvider>(context, listen: false)
                    .deleteCheckedTodos(_selectedDay);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
