import 'package:flutter_test/flutter_test.dart';
import 'package:academic_check/models/event.dart';
import 'package:academic_check/models/task.dart';
import 'package:academic_check/models/user.dart';
import 'package:academic_check/models/habit.dart';
import 'package:academic_check/services/web_storage_service.dart';
import 'package:academic_check/providers/app_state.dart';

void main() {
  group('Model serialization and copyWith', () {
    test('User model serialization', () {
      final date = DateTime(2026, 6, 17);
      final user = User(
        id: 1,
        email: 'test@example.com',
        passwordHash: 'hash123',
        createdAt: date,
      );

      final map = user.toMap();
      expect(map['id'], 1);
      expect(map['email'], 'test@example.com');
      expect(map['passwordHash'], 'hash123');
      expect(map['createdAt'], date.toIso8601String());

      final fromMap = User.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.email, 'test@example.com');
      expect(fromMap.passwordHash, 'hash123');
      expect(fromMap.createdAt, date);

      final copied = user.copyWith(
        id: 2,
        email: 'copied@example.com',
        passwordHash: 'hash456',
        createdAt: DateTime(2026, 6, 18),
      );
      expect(copied.id, 2);
      expect(copied.email, 'copied@example.com');
      expect(copied.passwordHash, 'hash456');
      expect(copied.createdAt, DateTime(2026, 6, 18));

      final copiedNull = user.copyWith();
      expect(copiedNull.id, 1);
      expect(copiedNull.email, 'test@example.com');
    });

    test('Task model serialization', () {
      final date = DateTime(2026, 6, 17);
      final task = Task(
        id: 1,
        userId: 10,
        title: 'Task 1',
        description: 'Description 1',
        dueDate: date,
        priority: 'Alta',
        completed: true,
      );

      final map = task.toMap();
      expect(map['id'], 1);
      expect(map['userId'], 10);
      expect(map['title'], 'Task 1');
      expect(map['description'], 'Description 1');
      expect(map['dueDate'], date.toIso8601String());
      expect(map['priority'], 'Alta');
      expect(map['completed'], 1);

      final fromMap = Task.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.userId, 10);
      expect(fromMap.title, 'Task 1');
      expect(fromMap.description, 'Description 1');
      expect(fromMap.dueDate, date);
      expect(fromMap.priority, 'Alta');
      expect(fromMap.completed, true);

      final copied = task.copyWith(
        id: 2,
        userId: 20,
        title: 'Task 2',
        description: 'Description 2',
        dueDate: DateTime(2026, 6, 18),
        priority: 'Baja',
        completed: false,
      );
      expect(copied.id, 2);
      expect(copied.userId, 20);
      expect(copied.title, 'Task 2');
      expect(copied.completed, false);

      final copiedNull = task.copyWith();
      expect(copiedNull.id, 1);
      expect(copiedNull.title, 'Task 1');
    });

    test('Event model serialization', () {
      final startDate = DateTime(2026, 6, 17, 10);
      final endDate = DateTime(2026, 6, 17, 12);
      final event = Event(
        id: 5,
        userId: 10,
        title: 'Event 1',
        description: 'Description 1',
        startDate: startDate,
        endDate: endDate,
      );

      final map = event.toMap();
      expect(map['id'], 5);
      expect(map['userId'], 10);
      expect(map['title'], 'Event 1');
      expect(map['description'], 'Description 1');
      expect(map['startDate'], startDate.toIso8601String());
      expect(map['endDate'], endDate.toIso8601String());

      final fromMap = Event.fromMap(map);
      expect(fromMap.id, 5);
      expect(fromMap.userId, 10);
      expect(fromMap.title, 'Event 1');
      expect(fromMap.description, 'Description 1');
      expect(fromMap.startDate, startDate);
      expect(fromMap.endDate, endDate);

      final copied = event.copyWith(
        id: 6,
        userId: 20,
        title: 'Event 2',
        description: 'Description 2',
        startDate: DateTime(2026, 6, 18),
        endDate: DateTime(2026, 6, 19),
      );
      expect(copied.id, 6);
      expect(copied.userId, 20);
      expect(copied.title, 'Event 2');

      final copiedNull = event.copyWith();
      expect(copiedNull.id, 5);
      expect(copiedNull.title, 'Event 1');
    });

    test('Habit model copyWith and defaults', () {
      final createdDate = DateTime(2026, 6, 15);
      final habit = Habit(
        id: 3,
        userId: 10,
        title: 'Habit 1',
        description: 'Desc 1',
        createdAt: createdDate,
        completionDates: [DateTime(2026, 6, 16)],
        isCompleted: false,
      );

      final copied = habit.copyWith(
        id: 4,
        userId: 11,
        title: 'Habit 2',
        description: 'Desc 2',
        createdAt: DateTime(2026, 6, 16),
        completionDates: [],
        isCompleted: true,
      );
      expect(copied.id, 4);
      expect(copied.userId, 11);
      expect(copied.title, 'Habit 2');
      expect(copied.isCompleted, true);

      final copiedNull = habit.copyWith();
      expect(copiedNull.id, 3);
      expect(copiedNull.title, 'Habit 1');
    });
  });

  group('WebStorageService Complete Tests', () {
    late WebStorageService service;

    setUp(() async {
      service = WebStorageService();
      await service.init();
    });

    test('User CRUD operations', () async {
      final user = User(
        email: 'test@example.com',
        passwordHash: 'hash123',
        createdAt: DateTime.now(),
      );

      // Create
      final created = await service.createUser(user);
      expect(created, isNotNull);
      expect(created!.id, 1);
      expect(created.email, 'test@example.com');

      // Create duplicate email should return null
      final duplicate = await service.createUser(user);
      expect(duplicate, isNull);

      // Get by email
      final fetched = await service.getUserByEmail('test@example.com');
      expect(fetched, isNotNull);
      expect(fetched!.email, 'test@example.com');

      // Get by email (nonexistent)
      final missing = await service.getUserByEmail('missing@example.com');
      expect(missing, isNull);

      // Get user with correct credentials
      final authenticated = await service.getUser('test@example.com', 'hash123');
      expect(authenticated, isNotNull);

      // Get user with wrong credentials
      final wrong = await service.getUser('test@example.com', 'wrong_hash');
      expect(wrong, isNull);

      // Update User
      final updatedUser = fetched.copyWith(email: 'newemail@example.com');
      final updateSuccess = await service.updateUser(updatedUser);
      expect(updateSuccess, isTrue);

      final afterUpdate = await service.getUserByEmail('newemail@example.com');
      expect(afterUpdate, isNotNull);

      // Update non-existent user
      final nonExistentUser = User(id: 999, email: 'no@example.com', passwordHash: '', createdAt: DateTime.now());
      final nonExistentSuccess = await service.updateUser(nonExistentUser);
      expect(nonExistentSuccess, isFalse);
    });

    test('Task CRUD operations', () async {
      final task = Task(
        userId: 1,
        title: 'Task A',
        description: 'Desc A',
        dueDate: DateTime(2026, 6, 20),
        priority: 'Alta',
      );

      // Create
      final created = await service.createTask(task);
      expect(created.id, 1);

      // Read tasks
      final tasks = await service.getTasks(1);
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Task A');

      // Update
      final updatedTask = created.copyWith(title: 'Task A Updated');
      await service.updateTask(updatedTask);
      final tasks2 = await service.getTasks(1);
      expect(tasks2.first.title, 'Task A Updated');

      // Update non-existent task (no-op)
      final nonExistentTask = created.copyWith(id: 999, title: 'No effect');
      await service.updateTask(nonExistentTask);

      // Delete
      await service.deleteTask(created.id!);
      final tasks3 = await service.getTasks(1);
      expect(tasks3.isEmpty, isTrue);
    });

    test('Event CRUD operations', () async {
      final event = Event(
        userId: 1,
        title: 'Event A',
        description: 'Desc A',
        startDate: DateTime(2026, 6, 20, 10),
        endDate: DateTime(2026, 6, 20, 12),
      );

      // Create
      final created = await service.createEvent(event);
      expect(created.id, 1);

      // Read
      final events = await service.getEvents(1);
      expect(events.length, 1);
      expect(events.first.title, 'Event A');

      // Update
      final updatedEvent = created.copyWith(title: 'Event A Updated');
      await service.updateEvent(updatedEvent);
      final events2 = await service.getEvents(1);
      expect(events2.first.title, 'Event A Updated');

      // Update non-existent event (no-op)
      final nonExistentEvent = created.copyWith(id: 999, title: 'No effect');
      await service.updateEvent(nonExistentEvent);

      // Delete
      await service.deleteEvent(created.id!);
      final events3 = await service.getEvents(1);
      expect(events3.isEmpty, isTrue);
    });

    test('Session operations', () async {
      expect(await service.getSession(), isNull);

      await service.saveSession('user@example.com');
      expect(await service.getSession(), 'user@example.com');

      await service.clearSession();
      expect(await service.getSession(), isNull);
    });

    test('Habit CRUD operations', () async {
      final habit = Habit(
        userId: 1,
        title: 'Habit A',
        description: 'Desc A',
        createdAt: DateTime.now(),
        completionDates: [],
      );

      // Create
      final created = await service.createHabit(habit);
      expect(created.id, 1);

      // Read
      final habits = await service.getHabits(1);
      expect(habits.length, 1);

      // Update
      final updated = created.copyWith(title: 'Habit A Updated');
      await service.updateHabit(updated);
      final habits2 = await service.getHabits(1);
      expect(habits2.first.title, 'Habit A Updated');

      // Update non-existent (no-op)
      final nonExistent = created.copyWith(id: 999, title: 'No effect');
      await service.updateHabit(nonExistent);

      // Delete
      await service.deleteHabit(created.id!);
      final habits3 = await service.getHabits(1);
      expect(habits3.isEmpty, isTrue);
    });
  });

  group('AppState Complete Tests', () {
    late WebStorageService storageService;
    late AppState appState;

    setUp(() async {
      storageService = WebStorageService();
      await storageService.init();
      appState = AppState(storageService: storageService);
    });

    test('Theme toggling', () {
      expect(appState.isDarkMode, isTrue);
      appState.toggleTheme();
      expect(appState.isDarkMode, isFalse);
    });

    test('Auth error clearing', () {
      // Simulate an error
      expect(appState.authError, isNull);
      appState.clearAuthError();
      expect(appState.authError, isNull);
    });

    test('Register offline, login, auto login, logout', () async {
      // Register
      final registerResult = await appState.registerOffline('user@example.com', 'secret123');
      expect(registerResult, isTrue);
      expect(appState.currentUser, isNotNull);
      expect(appState.currentUser!.email, 'user@example.com');

      // Duplicate registration should fail
      final registerDuplicate = await appState.registerOffline('user@example.com', 'another');
      expect(registerDuplicate, isFalse);
      expect(appState.authError, 'El correo electrónico ya está registrado.');

      // Logout
      await appState.logout();
      expect(appState.currentUser, isNull);
      expect(appState.tasks.isEmpty, isTrue);

      // Try auto login
      await appState.tryAutoLogin();
      expect(appState.currentUser, isNull); // session was cleared

      // Normal Login success
      final loginSuccess = await appState.signInWithSupabase('user@example.com', 'secret123');
      expect(loginSuccess, isTrue);
      expect(appState.currentUser!.email, 'user@example.com');

      // Test auto login with session
      await appState.logout();
      await storageService.saveSession('user@example.com');
      await appState.tryAutoLogin();
      expect(appState.currentUser, isNotNull);
      expect(appState.currentUser!.email, 'user@example.com');

      // Login wrong credentials
      await appState.logout();
      final loginFail = await appState.signInWithSupabase('user@example.com', 'wrongpass');
      expect(loginFail, isFalse);
      expect(appState.authError, 'Correo electrónico o contraseña incorrectos.');

      // Login with Demo user auto-creation
      final demoLogin = await appState.signInWithSupabase('demo@example.com', 'anypass');
      expect(demoLogin, isTrue);
      expect(appState.currentUser!.email, 'demo@example.com');
    });

    test('Email uniqueness and check exists', () async {
      final isUniqueBefore = await appState.checkEmailUnique('unique@example.com');
      expect(isUniqueBefore, isTrue);

      await appState.registerOffline('unique@example.com', 'pass');

      final isUniqueAfter = await appState.checkEmailUnique('unique@example.com');
      expect(isUniqueAfter, isFalse);

      final exists = await appState.checkEmailExists('unique@example.com');
      expect(exists, isTrue);

      final nonExistent = await appState.checkEmailExists('missing@example.com');
      expect(nonExistent, isFalse);
    });

    test('Update password local fallback', () async {
      await appState.registerOffline('passupdate@example.com', 'oldpass');
      final updateSuccess = await appState.updateSupabasePassword('newpass');
      expect(updateSuccess, isTrue);

      // Verify log in with new password
      await appState.logout();
      final loginResult = await appState.signInWithSupabase('passupdate@example.com', 'newpass');
      expect(loginResult, isTrue);
    });

    test('Task CRUD via AppState', () async {
      await appState.registerOffline('taskuser@example.com', 'pass');

      // Create task
      await appState.addTask(
        title: 'Work Task',
        description: 'Do the job',
        dueDate: DateTime(2026, 6, 20),
        priority: 'Alta',
      );
      expect(appState.tasks.length, 1);
      expect(appState.tasks.first.title, 'Work Task');

      // Toggle completed
      await appState.toggleTaskCompleted(appState.tasks.first);
      expect(appState.tasks.first.completed, isTrue);

      // Update task
      final taskToUpdate = appState.tasks.first.copyWith(title: 'Work Task Updated');
      await appState.updateTask(taskToUpdate);
      expect(appState.tasks.first.title, 'Work Task Updated');

      // Delete task
      await appState.deleteTask(appState.tasks.first.id!);
      expect(appState.tasks.isEmpty, isTrue);
    });

    test('Event CRUD via AppState', () async {
      await appState.registerOffline('eventuser@example.com', 'pass');

      // Add event
      await appState.addEvent(
        title: 'Meeting',
        description: 'Sprint planning',
        startDate: DateTime(2026, 6, 20, 9),
        endDate: DateTime(2026, 6, 20, 10),
      );
      expect(appState.events.length, 1);
      expect(appState.events.first.title, 'Meeting');

      // Update event
      final eventToUpdate = appState.events.first.copyWith(title: 'Meeting Updated');
      await appState.updateEvent(eventToUpdate);
      expect(appState.events.first.title, 'Meeting Updated');

      // Delete event
      await appState.deleteEvent(appState.events.first.id!);
      expect(appState.events.isEmpty, isTrue);
    });

    test('Habit CRUD and Toggle completion dates', () async {
      await appState.registerOffline('habituser@example.com', 'pass');

      // Add habit
      final addResult = await appState.addHabit(title: 'Gym', description: 'Go to gym');
      expect(addResult, isTrue);
      expect(appState.habits.length, 1);
      expect(appState.habits.first.title, 'Gym');

      // Update habit
      final habitToUpdate = appState.habits.first.copyWith(description: 'Go to gym daily');
      await appState.updateHabit(habitToUpdate);
      expect(appState.habits.first.description, 'Go to gym daily');

      // Toggle completed status
      await appState.toggleHabitCompletedStatus(appState.habits.first);
      expect(appState.habits.first.isCompleted, isTrue);
      await appState.toggleHabitCompletedStatus(appState.habits.first);
      expect(appState.habits.first.isCompleted, isFalse);

      // Toggle completion date adding and removing
      final today = DateTime.now();
      final streakCompleted = await appState.toggleHabitCompletionDate(appState.habits.first, today);
      expect(streakCompleted, isFalse);
      expect(appState.habits.first.completionDates.length, 1);

      // Toggle same date again (removes it)
      final streakCompletedAfterRemove = await appState.toggleHabitCompletionDate(appState.habits.first, today);
      expect(streakCompletedAfterRemove, isFalse);
      expect(appState.habits.first.completionDates.isEmpty, isTrue);

      // Delete habit
      await appState.deleteHabit(appState.habits.first.id!);
      expect(appState.habits.isEmpty, isTrue);
    });

    test('Habit 21-day consecutive streak Auto-Completion', () async {
      await appState.registerOffline('streakuser@example.com', 'pass');
      await appState.addHabit(title: 'Streak Habit', description: '');
      
      final habit = appState.habits.first;
      final dates = <DateTime>[];
      final today = DateTime.now();
      
      // We toggle 20 consecutive days (excluding today)
      for (int i = 20; i >= 1; i--) {
        final d = today.subtract(Duration(days: i));
        dates.add(DateTime(d.year, d.month, d.day));
      }

      final almostDoneHabit = habit.copyWith(completionDates: dates);
      await storageService.updateHabit(almostDoneHabit);
      await appState.loadHabits();

      // Today's toggle will complete the 21-day streak
      final completed = await appState.toggleHabitCompletionDate(appState.habits.first, today);
      expect(completed, isTrue);
      expect(appState.habits.first.isCompleted, isTrue);
    });
  });
}
