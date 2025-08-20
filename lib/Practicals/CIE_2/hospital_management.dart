class Patient {
  int patientId;
  String name;
  int age;
  String illness;
  int assignedDoctorId;

  Patient(
    this.patientId,
    this.name,
    this.age,
    this.illness,
    this.assignedDoctorId,
  );
}

class Doctor {
  int doctorId;
  String name;
  String specialization;
  List<int> assignedPatientIds;

  Doctor(
    this.doctorId,
    this.name,
    this.specialization,
    this.assignedPatientIds,
  );
}

class Appointment {
  int appointmentId;
  int patientId;
  int doctorId;
  DateTime dateTime;
  String status;

  Appointment(
    this.appointmentId,
    this.patientId,
    this.doctorId,
    this.dateTime,
    this.status,
  );
}

class HospitalManagement {
  List<Patient> patients = [];
  List<Doctor> doctors = [];
  List<Appointment> appointments = [];

  void doctorassigntopatient(int patientId, int doctorId) {
    Patient? patient = this.patients.firstWhere(
      (p) => p.patientId == patientId,
    );
    Doctor? doctor = this.doctors.firstWhere(
      (d) => d.doctorId == doctorId,
    );
    patient.assignedDoctorId = doctor.doctorId;
    doctor.assignedPatientIds.add(patient.patientId);

    print("Doctor ${doctor.name} assigned to patient ${patient.name}");
  }

  void scheduleAppointment(int appointmentId, int patientId, int doctorId, DateTime dateTime) { 
    Doctor? doctor = this.doctors.firstWhere(
      (d) => d.doctorId == doctorId,
    );

    int count = appointments.where((a) => a.doctorId == doctorId && a.dateTime == dateTime).length;
    if (count >= 3) {
      print("Cannot schedule appointment. Doctor ${doctor.name} already has 3 appointments at this time.");
      return;
    } else {
    Appointment newAppointment = Appointment(appointmentId, patientId, doctorId, dateTime, "Scheduled");
    appointments.add(newAppointment);
    print("Appointment scheduled for patient ID ${patientId} with doctor ID ${doctorId} on ${dateTime}"); 
    }
   }
  
}

void main(){
  HospitalManagement h1 = HospitalManagement();
  h1.patients.add(Patient(1, "Samarth", 30, "fracture", 2));
  h1.patients.add(Patient(2, "Jaimin", 25, "fever", 1));
  h1.patients.add(Patient(3, "Rohan", 22, "headache", 3));
  h1.patients.add(Patient(4, "Ravi", 28, "cough", 1));
  h1.patients.add(Patient(5, "Sahil", 35, "cold", 1));

  h1.doctors.add(Doctor(1, "Dr. Rahul", "general", []));
  h1.doctors.add(Doctor(2, "Dr. Ashok", "ortho", []));
  h1.doctors.add(Doctor(3, "Dr. Shubh", "psychologist", []));

  h1.doctorassigntopatient(1, 2);
  h1.doctorassigntopatient(2, 3);
  h1.doctorassigntopatient(3, 1);
  h1.doctorassigntopatient(4, 1);
  h1.doctorassigntopatient(5, 1);

  h1.scheduleAppointment(101, 1, 2, DateTime(2023, 10, 15, 10, 0));
  h1.scheduleAppointment(102, 2, 3, DateTime(2023, 10, 15, 11, 0));
  h1.scheduleAppointment(103, 3, 1, DateTime(2023, 10, 15, 12, 0));
  h1.scheduleAppointment(104, 4, 1, DateTime(2023, 10, 15, 13, 0));
  h1.scheduleAppointment(105, 5, 1, DateTime(2023, 10, 15, 14, 0)); 
}