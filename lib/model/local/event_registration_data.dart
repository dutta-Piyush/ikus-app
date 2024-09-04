class EventRegistrationData {

  final int? matriculationNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? address;
  final String? country;
  final String? dob;
  final Map<int, String> registrationTokens; // event id -> token

  EventRegistrationData({
    required this.matriculationNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.country,
    required this.dob,
    required this.registrationTokens
    
  });

  // get dob => null;

  Map<String, dynamic> toMap() {
    return {
      'matriculationNumber': matriculationNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'address': address,
      'country': country,
      'dob':dob,
      'registrationTokens': Map.fromIterable(registrationTokens.entries,
        key: (entry) => entry.key.toString(),
        value: (entry) => entry.value
      )
    };
  }

  EventRegistrationData copyWithNewTokens(Map<int, String> tokens) {
    return EventRegistrationData(
        matriculationNumber: matriculationNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        country: country,
        dob:dob,
        registrationTokens: tokens
    );
  }

  static EventRegistrationData fromMap(Map<String, dynamic> map) {
    return EventRegistrationData(
      matriculationNumber: map['matriculationNumber'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      address: map['address'],
      country: map['country'],
      dob:map['dob'],
      registrationTokens: Map.fromIterable(map['registrationTokens'].entries,
        key: (entry) => int.parse(entry.key),
        value: (entry) => entry.value
      )
    );
  }
}