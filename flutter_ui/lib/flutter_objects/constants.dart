import 'package:flutter_bus/flutter_objects/teacher.dart';
import 'bus.dart';
import 'package:flutter_bus/flutter_db_service/flutter_db_service.dart';

Future<List<Teacher>> teachers = fetchTeachers();

// [
//   Teacher(1, 'Ms. Arndt', 'First Grade'),
//   Teacher(2, 'Ms. Gertner', 'Second Grade'),
//   Teacher(3, 'Ms. Wagner', 'Third Grade'),
//     Teacher(4, 'Ms. Iacovetti', 'Third Grade'),
//   Teacher(5, 'Ms. LoGreco', 'Third Grade'),
//   Teacher(6, 'Ms. Palmer', 'Third Grade'),
//   Teacher(7, 'Ms. Williams', 'Third Grade'),
//   Teacher(8, 'Ms. Carlson', 'Third Grade'),
//   Teacher(9, 'Ms. M. Edinger', 'Third Grade'),
//   Teacher(10, 'Ms. Buchanan', 'Third Grade'),
//   Teacher(11, 'Ms. Roths', 'Third Grade'),
//   Teacher(12, 'Mr. A. Ricketts', 'Third Grade'),
//     Teacher(13, 'Ms. Muñoz', 'Third Grade'),
//   Teacher(14, 'Ms. Forker', 'Third Grade'),
//   Teacher(15, 'Ms. L. Ricketts', 'Third Grade'),
//   Teacher(16, 'Ms. Shell', 'Third Grade'),
//   Teacher(3, 'Ms. Leir Orlando', 'Third Grade'),
//   Teacher(3, 'Ms. Dimke', 'Third Grade'),
//   Teacher(3, 'Mr. J. Edinger', 'Third Grade'),
//   Teacher(3, 'Ms. Yackus', 'Third Grade'),
//   Teacher(3, 'Ms. Peters', 'Third Grade'),
//   Teacher(3, 'Ms. Rozinski', 'Third Grade'),
//   Teacher(3, 'Ms. Lakin', 'Third Grade'),

// ];

Future<List<Bus>> buses = fetchBuses();

// [
//   Bus(1, '2206', '🐌', false),
//   Bus(2, '2306', '🦖', false),
//   Bus(3, '1502', '🐘', false),
//   Bus(3, '1703', '🧸', false),
//   Bus(3, '2202', '🦅', false),
//   Bus(3, '1904', '🐿️', false),
//   Bus(3, '2104', '🐮', false),
//   Bus(3, '2305', '🐊', false),
//   Bus(3, '2028', '🦘', false),
// ];

