import 'package:dio/dio.dart';
import '../models/appointment.dart';

abstract class AppointmentsRemoteDataSource {
  Future<List<Appointment>> getMyAppointments();
  Future<Appointment> getAppointmentById(String id);
  Future<Appointment> bookAppointment(Map<String, dynamic> data);
  Future<Appointment> rescheduleAppointment(String id, Map<String, dynamic> data);
  Future<void> cancelAppointment(String id);
  Future<List<String>> getAvailableSlots(String date, String serviceType);
}

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  final Dio _dio;

  AppointmentsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Appointment>> getMyAppointments() async {
    final response = await _dio.get('/api/v1/appointments/my-appointments');
    return (response.data['data'] as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  @override
  Future<Appointment> getAppointmentById(String id) async {
    final response = await _dio.get('/api/v1/appointments/$id');
    return Appointment.fromJson(response.data['data']);
  }

  @override
  Future<Appointment> bookAppointment(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/appointments', data: data);
    return Appointment.fromJson(response.data['data']);
  }

  @override
  Future<Appointment> rescheduleAppointment(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/v1/appointments/$id', data: data);
    return Appointment.fromJson(response.data['data']);
  }

  @override
  Future<void> cancelAppointment(String id) async {
    await _dio.delete('/api/v1/appointments/$id');
  }

  @override
  Future<List<String>> getAvailableSlots(String date, String serviceType) async {
    final response = await _dio.get('/api/v1/appointments/available-slots', 
      queryParameters: {'date': date, 'serviceType': serviceType});
    return (response.data['data'] as List).cast<String>();
  }
}